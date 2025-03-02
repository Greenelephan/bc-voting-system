use anchor_client::anchor_lang::prelude::*;
use anchor_client::anchor_lang::system_program;
use chrono::Utc;
use salvo::{handler, Request, Response};
use salvo::http::StatusCode;
use salvo::prelude::Json;
use uuid::Uuid;
use voting_system::accounts as voting_accounts;
use voting_system::instruction as voting_instruction;
use voting_system::states::{
    Candidate,
    Registration,
    Voting,
    VotingList};
use crate::common::models::ApiResponse;
use crate::smart_contracts::solana::create_anchor_client;
use crate::smart_contracts::voting_system::models::{
    CandidateResponse,
    InitializeVotingRequest,
    OpenVotingsResponse,
    VotingStateInfo,
    VotingStatus,
    VotingStatusResponse};

#[handler]
pub async fn initialize_voting(req: &mut Request, res: &mut Response) {
    let init_req: InitializeVotingRequest = match req.parse_json().await {
        Ok(req) => req,
        Err(e) => {
            res.status_code(StatusCode::BAD_REQUEST);
            res.render(Json(serde_json::json!({ "error": format!("Invalid request: {}", e) })));
            return;
        }
    };

    let candidates_clone = init_req.candidates
        .iter()
        .map(|c| Candidate {
            id: 0,
            name: c.name.clone(),
            votes: 0,
        }).collect();

    let voting_id = Uuid::new_v4().to_string().split('-').next().unwrap().to_string();

    let result = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();

        let (voting_list, _) = Pubkey::find_program_address(&[b"voting_list"], &program.id());
        //Give unique pubkey to every initialized voting to distinguish them
        let (voting, _) = Pubkey::find_program_address(
            &[b"voting", program.payer().as_ref(), voting_id.as_bytes()], &program.id());

        program
            .request()
            .accounts(voting_accounts::InitializeVoting {
                voting,
                admin: program.payer(),
                voting_list,
                system_program: system_program::ID,
            })
            .args(voting_instruction::InitializeVoting {
                voting_id: voting_id.clone(),
                title: init_req.title.clone(),
                candidates: candidates_clone,
            })
            .send().expect("voting initialization failed");

        let voting: Voting = program.account(voting).unwrap();

        Ok::<Voting, AnchorError>(voting)
    })
        .await
        .unwrap();

    match result {
        //TODO: rewrite this complicated implementation
        Ok(voting) => {
            let voting_state_info = VotingStateInfo {
                is_voting_open: voting.is_open,
                is_registration_open: true,
            };

            let response = VotingStatusResponse {
                voting_id: voting.id,
                status: Some(VotingStatus::from_voting_state(&voting_state_info)),
                title: Some(voting.title),
                candidates: Some(
                    voting.candidates.iter()
                        .map(|c| CandidateResponse {
                            id: c.id,
                            name: c.name.clone(),
                            votes: c.votes,
                        })
                        .collect()
                ),
                candidates_count: Some(voting.candidates.len() as u64),
                total_votes: Some(voting.total_votes),
                total_registered_voters: Some(voting.total_registered_voters),
                timestamp: Some(Utc::now().to_rfc3339()),
            };
            res.render(Json(response))
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to initialize voting: {}", e),
            }));
        }
    }
}


#[handler]
pub async fn voting_statistic(res: &mut Response) {
    let result: Result<Vec<VotingStatusResponse>> = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();

        let (voting_list_pda, _) = Pubkey::find_program_address(&[b"voting_list"], &program.id());
        let voting_list: VotingList = program.account(voting_list_pda).unwrap();
        let (registration_pda, _) = Pubkey::find_program_address(&[b"registration"], &program.id());
        let registration: Registration = program.account(registration_pda).unwrap();

        let mut responses = Vec::new();

        for voting_id in &voting_list.voting_ids {
            let (voting_pda, _) = Pubkey::find_program_address(
                &[b"voting", program.payer().as_ref(), voting_id.as_ref()],
                &program.id()
            );

            let voting: Voting = program.account(voting_pda).unwrap();
            let candidates: Vec<CandidateResponse> = voting.candidates
                .iter()
                .map(|c| CandidateResponse {
                    id: c.id,
                    name: c.name.clone(),
                    votes: c.votes,
                })
                .collect();

            let voting_state_info = VotingStateInfo {
                is_voting_open: voting.is_open,
                is_registration_open: registration.is_open,
            };

            responses.push(VotingStatusResponse {
                voting_id: voting.id,
                status: Option::from(VotingStatus::from_voting_state(&voting_state_info)),
                title: None,
                total_registered_voters: Option::from(voting.total_registered_voters),
                total_votes: Option::from(voting.total_votes),
                candidates: Option::from(candidates),
                candidates_count: None,
                timestamp: Option::from(Utc::now().to_rfc3339()),
            });
        }

        Ok(responses)
    })
        .await
        .unwrap();

    match result {
        Ok(statuses) => {
            res.render(Json(statuses))
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to get voting process statuses: {}", e),
            }))
        }
    }
}

#[handler]
pub async fn open_votings(res: &mut Response) {
    let result: Result<OpenVotingsResponse> = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        // Try to get voting list account
        let (voting_list_account, _) = Pubkey::find_program_address(&[b"voting_list"], &program.id());

        match program.account::<VotingList>(voting_list_account) {
            Ok(voting_list) => {
                let mut list_of_votings = Vec::new();

                // Fetch details for each voting
                for voting_id in &voting_list.voting_ids {
                    let (voting_pda, _) = Pubkey::find_program_address(
                        &[b"voting", program.payer().as_ref(), voting_id.as_ref()],
                        &program.id()
                    );

                    let voting: Voting = program.account(voting_pda).unwrap();

                    if voting.is_open {
                        list_of_votings.push(VotingStatusResponse {
                            voting_id: voting.id,
                            status: None,
                            title: Some(voting.title),
                            total_registered_voters: None,
                            total_votes: None,
                            candidates: None,
                            candidates_count: None,
                            timestamp: None,
                        });
                    }
                }

                Ok(OpenVotingsResponse {
                    open_votings: list_of_votings,
                })
            }
            Err(_) => {
                // Return empty list if voting list doesn't exist yet
                Ok(OpenVotingsResponse {
                    open_votings: Vec::new(),
                })
            }
        }
    })
    .await
    .unwrap();

    match result {
        Ok(response) => {
            res.render(Json(response));
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to fetch open votings: {}", e),
            }));
        }
    }
}

#[handler]
pub async fn voting_status(req: &mut Request, res: &mut Response) {
    let voting_id = req.param::<String>("votingId").unwrap();

    let result: Result<VotingStatusResponse> = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (voting, _) = Pubkey::find_program_address(
            &[b"voting", program.payer().as_ref(), voting_id.as_bytes()], &program.id());

        let voting: Voting = program.account(voting).unwrap();

        let voting_state =
            if voting.is_open {VotingStatus::Open} else {VotingStatus::Closed};

        Ok(VotingStatusResponse {
            voting_id,
            status: Some(voting_state),
            title: Some(voting.title),
            candidates: Some(
                voting.candidates
                    .iter().map(|c| CandidateResponse {
                    id: c.id,
                    name: c.name.clone(),
                    votes: c.votes,
                }).collect()),
            candidates_count: None,
            total_votes: Some(voting.total_votes),
            total_registered_voters: None,
            timestamp: Some(Utc::now().to_rfc3339()),
        })
    })
        .await
        .unwrap();

    match result {
        Ok(status) => {
            res.render(Json(status))
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to get voting status: {}", e)
            }))
        }
    }
}

#[handler]
pub async fn voting_info(req: &mut Request, res: &mut Response) {
    let voting_id = req.param::<String>("votingId").unwrap();

    let result: Result<VotingStatusResponse> = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (voting, _) = Pubkey::find_program_address(
            &[b"voting", program.payer().as_ref(), voting_id.as_bytes()], &program.id());
        let voting: Voting = program.account(voting).unwrap();
        let (registration, _) = Pubkey::find_program_address(&[b"registration"], &program.id());
        let registration: Registration = program.account(registration).unwrap();

        let voting_state_info = VotingStateInfo {
            is_voting_open: voting.is_open,
            is_registration_open: registration.is_open,
        };

        Ok(VotingStatusResponse {
            voting_id,
            status: Some(VotingStatus::from_voting_state(&voting_state_info)),
            title: None,
            candidates:  None,
            candidates_count: Some(voting.candidates.len() as u64),
            total_votes: Some(voting.total_votes),
            total_registered_voters: None,
            timestamp: Some(Utc::now().to_rfc3339()),
        })
    })
        .await
        .unwrap();

    match result {
        Ok(status) => {
            res.render(Json(status))
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to get voting info: {}", e)
            }))
        }
    }
}



#[handler]
pub async fn finalize_voting(req: &mut Request, res: &mut Response) {
    let voting_id = req.param::<String>("votingId").unwrap();

    let result = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (voting, _) = Pubkey::find_program_address(
            &[b"voting", program.payer().as_ref(), voting_id.as_bytes()], &program.id());

        program
            .request()
            .accounts(voting_accounts::FinalizeVoting {
                voting,
                admin: program.payer(),
            })
            .args(voting_instruction::FinalizeVoting {
                voting_id: voting_id.clone()
            })
            .send()
    })
        .await
        .unwrap();

    match result {
        Ok(_) => {
            res.render(Json(ApiResponse {
                success: true,
                message: "Voting finalized successfully".to_string(),
            }));
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to finalize voting: {}", e),
            }));
        }
    }
}
