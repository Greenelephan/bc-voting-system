use crate::common::models::{ApiResponse, Claims};
use crate::smart_contracts::solana::create_anchor_client;
use crate::smart_contracts::voter::models::{
    CastVoteRequest,
    CastVoteResponse,
    VoteStatus,
    VoteStatusResponse,
    VoterStatusResponse};
use crate::common::utils::{generate_receipt_id, extract_voting_id};
use anchor_client::anchor_lang::prelude::*;
use chrono::Utc;
use salvo::http::StatusCode;
use salvo::prelude::Json;
use salvo::{handler, Depot, Request, Response};
use voting_system::states::Voter;
use voting_system::accounts as voting_accounts;
use voting_system::instruction as voting_instruction;

#[handler]
pub async fn voter_status(req: &mut Request, depot: &mut Depot, res: &mut Response) {
    let voter_id = req.param::<String>("voterId").unwrap();
    let claims = depot.get::<Claims>("user_claims").unwrap();

    if claims.sub != voter_id {
        res.status_code(StatusCode::FORBIDDEN);
        res.render(Json(ApiResponse {
            success: false,
            message: "You can only request your own voter status".to_string(),
        }));
        return;
    }

    let result: Result<VoterStatusResponse> = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let admin_pubkey = program.payer();
        let (voter_account, _) = Pubkey::find_program_address(
            &[b"voter", admin_pubkey.as_ref(), voter_id.as_bytes()],
            &program.id(),
        );

        match program.account::<Voter>(voter_account) {
            Ok(voter) => Ok(VoterStatusResponse {
                voter_id,
                is_registered: voter.is_registered,
                has_voted: voter.has_voted,
                timestamp: Utc::now().to_rfc3339(),
            }),
            Err(_) => Ok(VoterStatusResponse {
                voter_id,
                is_registered: false,
                has_voted: false,
                timestamp: Utc::now().to_rfc3339(),
            })
        }
    })
    .await
    .unwrap();

    match result {
        Ok(status) => res.render(Json(status)),
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to get voter status: {}", e),
            }))
        }
    }
}

#[handler]
pub async fn cast_vote(req: &mut Request, depot: &mut Depot, res: &mut Response) {
    let claims = depot.get::<Claims>("user_claims").unwrap();

    let vote_req: CastVoteRequest = match req.parse_json().await {
        Ok(req) => req,
        Err(e) => {
            res.status_code(StatusCode::BAD_REQUEST);
            res.render(Json(serde_json::json!({ "error": format!("Invalid request: {}", e) })));
            return;
        }
    };

    let voter_id = claims.sub.clone();
    let voting_id = vote_req.voting_id.clone();

    let result: Result<CastVoteResponse> = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (voting_pda, _) = Pubkey::find_program_address(
            &[b"voting", program.payer().as_ref(), voting_id.as_ref()],
            &program.id(),
        );

        let admin_pubkey = program.payer();

        // Generate the voter account PDA using both admin's pubkey and voter_id
        let (voter_account, _) = Pubkey::find_program_address(
            &[b"voter", admin_pubkey.as_ref(), voter_id.as_bytes()],
            &program.id(),
        );

        program
            .request()
            .accounts(voting_accounts::CastVote {
                voting: voting_pda,
                voter: voter_account,
                admin: admin_pubkey,
            })
            .args(voting_instruction::CastVote {
                voting_id: voting_id.clone(),
                candidate_id: vote_req.candidate_id,
            })
            .send().expect("Vote cast failed on Blockchain level");

        let timestamp = Utc::now().to_rfc3339();
        let receipt_id = generate_receipt_id(&voting_id, &timestamp);

        let response = CastVoteResponse {
            success: true,
            receipt_id,
            timestamp,
        };

        Ok(response)
    })
        .await
        .unwrap();

    match result {
        Ok(response) => {
            res.render(Json(response))
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to cast vote: {}", e),
            }));
        }
    }
}

#[handler]
pub async fn vote_status(req: &mut Request, depot: &mut Depot, res: &mut Response) {
    let voter_id = req.param::<String>("voterId").unwrap();

    let claims = depot.get::<Claims>("user_claims").unwrap();

    if claims.sub != voter_id {
        res.status_code(StatusCode::FORBIDDEN);
        res.render(Json(ApiResponse {
            success: false,
            message: "You can only request your own voter status".to_string(),
        }));
        return;
    }

    let receipt_id = req.param::<String>("receiptId").unwrap();

    let voting_id = match extract_voting_id(&receipt_id) {
        Ok(id) => id,
        Err(e) => {
            res.status_code(StatusCode::BAD_REQUEST);
            res.render(Json(serde_json::json!({ "error": e })));
            return;
        }
    };

    let result: Result<VoteStatusResponse> = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (voter_account, _) = Pubkey::find_program_address(
            &[b"voter", program.payer().as_ref(), voter_id.as_bytes()],
            &program.id(),
        );

        let voter: Voter = program.account(voter_account).unwrap();
        let status = if voter.voted_votings.contains(&voting_id) {
            VoteStatus::COUNTED
        } else { VoteStatus::REJECTED };
        Ok(VoteStatusResponse {
            status,
            timestamp: Utc::now().to_rfc3339(),
        })
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
                message: format!("Failed to check vote status: {}", e),
            }));
        }
    }
}
