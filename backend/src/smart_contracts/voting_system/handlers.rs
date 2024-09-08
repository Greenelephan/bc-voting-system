use anchor_client::anchor_lang;
use anchor_client::anchor_lang::prelude::Pubkey;
use chrono::Utc;
use salvo::{handler, Request, Response};
use salvo::http::StatusCode;
use salvo::prelude::Json;
use voting_system::accounts as voting_accounts;
use voting_system::instruction as voting_instruction;
use crate::auth::jwt::validate_jwt;
use crate::models::models::{ApiResponse, InitializeVotingRequest, CastVoteRequest, VotingResponse};
use crate::smart_contracts::solana::create_anchor_client;

#[handler]
pub async fn initialize_voting(req: &mut Request, res: &mut Response) {
    let auth_header = req.headers().get("Authorization");

    let token = match auth_header {
        Some(value) => {
            let auth_str = value.to_str().unwrap_or("");
            if auth_str.starts_with("Bearer ") {
                &auth_str[7..]
            } else {
                ""
            }
        }
        None => "",
    };

    let claims = match validate_jwt(token) {
        Ok(claims) => claims,
        Err(_) => {
            res.status_code(StatusCode::UNAUTHORIZED);
            res.render(Json(serde_json::json!({ "error": "Invalid token" })));
            return;
        }
    };

    if claims.role != "admin" {
        res.status_code(StatusCode::FORBIDDEN);
        res.render(Json(serde_json::json!({ "error": "Access denied" })));
        return;
    }

    let init_req: InitializeVotingRequest = match req.parse_json().await {
        Ok(req) => req,
        Err(e) => {
            res.status_code(StatusCode::BAD_REQUEST);
            res.render(Json(serde_json::json!({ "error": format!("Invalid request: {}", e) })));
            return;
        }
    };

    let candidates_clone = init_req.candidates.clone();

    let result = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (voting, _) = Pubkey::find_program_address(&[b"voting"], &program.id());

        program
            .request()
            .accounts(voting_accounts::InitializeVoting {
                voting,
                admin: program.payer(),
                system_program: anchor_lang::system_program::ID,
            })
            .args(voting_instruction::InitializeVoting {
                candidates: candidates_clone,
            })
            .send()
    })
        .await
        .unwrap();

    match result {
        Ok(_) => {
            res.render(Json(VotingResponse {
                voting_id: "unique_voting_id".to_string(), // Generate a unique ID
                status: "open".to_string(),
                candidates: init_req.candidates.iter().enumerate().map(|(id, name)| serde_json::json!({
                    "id": id,
                    "name": name
                })).collect(),
                timestamp: Utc::now().to_rfc3339(),
            }));
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
pub async fn cast_vote(req: &mut Request, res: &mut Response) {
    let auth_header = req.headers().get("Authorization");

    let token = match auth_header {
        Some(value) => {
            let auth_str = value.to_str().unwrap_or("");
            if auth_str.starts_with("Bearer ") {
                &auth_str[7..]
            } else {
                ""
            }
        }
        None => "",
    };

    let claims = match validate_jwt(token) {
        Ok(claims) => claims,
        Err(_) => {
            res.status_code(StatusCode::UNAUTHORIZED);
            res.render(Json(serde_json::json!({ "error": "Invalid token" })));
            return;
        }
    };

    if claims.role != "voter" {
        res.status_code(StatusCode::FORBIDDEN);
        res.render(Json(serde_json::json!({ "error": "Access denied" })));
        return;
    }

    let vote_req: CastVoteRequest = match req.parse_json().await {
        Ok(req) => req,
        Err(e) => {
            res.status_code(StatusCode::BAD_REQUEST);
            res.render(Json(serde_json::json!({ "error": format!("Invalid request: {}", e) })));
            return;
        }
    };

    let voter_id = claims.sub.clone();

    let result = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (voting, _) = Pubkey::find_program_address(&[b"voting"], &program.id());

        let admin_pubkey = program.payer();

        // Generate the voter account PDA using both admin's pubkey and voter_id
        let (voter_account, _) = Pubkey::find_program_address(
            &[b"voter", admin_pubkey.as_ref(), voter_id.as_bytes()],
            &program.id()
        );

        program
            .request()
            .accounts(voting_accounts::CastVote {
                voting,
                voter: voter_account,
                user: admin_pubkey,
            })
            .args(voting_instruction::CastVote {
                candidate_id: vote_req.candidate_id,
            })
            .send()
    })
        .await
        .unwrap();

    match result {
        Ok(_) => {
            res.render(Json(serde_json::json!({
                "success": true,
                "receiptId": format!("receipt_{}", Utc::now().timestamp()),
                "timestamp": Utc::now().to_rfc3339(),
            })));
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
pub async fn finalize_voting(res: &mut Response) {
    let result = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (voting, _) = Pubkey::find_program_address(&[b"voting"], &program.id());

        program
            .request()
            .accounts(voting_accounts::FinalizeVoting {
                voting,
                admin: program.payer(),
            })
            .args(voting_instruction::FinalizeVoting {})
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