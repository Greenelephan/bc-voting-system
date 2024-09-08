use anchor_client::anchor_lang;
use anchor_client::anchor_lang::prelude::Pubkey;
use chrono::Utc;
use salvo::{handler, Request, Response};
use salvo::http::StatusCode;
use salvo::prelude::Json;
use voter_registration::accounts as voter_registration_accounts;
use voter_registration::instruction as voter_registration_instruction;
use crate::auth::jwt::validate_jwt;
use crate::models::models::{ApiResponse, VoterRegistrationResponse};
use crate::smart_contracts::solana::create_anchor_client;


#[handler]
pub async fn register_voter(req: &mut Request, res: &mut Response) {
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

    let voter_id = claims.sub.clone();

    let result = tokio::task::spawn_blocking({
        let voter_id_clone = voter_id.clone();
        move || {
            let client = create_anchor_client();
            let program = client.program(voter_registration::ID).unwrap();

            let admin_pubkey = program.payer();

            let (registration, _) = Pubkey::find_program_address(&[b"registration"], &program.id());

            // Generate the voter account PDA using both admin's pubkey and voter_id
            let (voter_account, _) = Pubkey::find_program_address(
                &[b"voter", admin_pubkey.as_ref(), voter_id_clone.as_bytes()],
                &program.id()
            );

            println!("Checking voter with ID: {}", voter_id_clone);
            println!("Admin pubkey: {}", admin_pubkey);
            println!("Voter account: {}", voter_account);


            println!("Registering new voter");
            let result = program
                .request()
                .accounts(voter_registration_accounts::RegisterVoter {
                    registration,
                    voter: voter_account,
                    user: admin_pubkey,  // Admin is still the payer
                    system_program: anchor_lang::system_program::ID,
                })
                .args(voter_registration_instruction::RegisterVoter { voter_id: voter_id_clone })
                .send();

            result.map(|_| voter_account.to_string())
        }
    })
        .await;

    match result {
        Ok(Ok(registration_token)) => {
            res.render(Json(VoterRegistrationResponse {
                voter_id: voter_id,
                registration_token,
                timestamp: Utc::now().to_rfc3339(),
            }));
        }
        Ok(Err(e)) => {
            println!("Detailed error: {:?}", e);
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(
                serde_json::json!({ "error": format!("Failed to register voter: {}", e) }),
            ));
        }
        Err(e) => {
            println!("Task execution error: {:?}", e);
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(
                serde_json::json!({ "error": format!("Task execution failed: {}", e) }),
            ));
        }
    }
}

#[handler]
pub async fn initialize_registration(res: &mut Response) {
    let result = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voter_registration::ID).unwrap();
        let (registration, _) = Pubkey::find_program_address(&[b"registration"], &program.id());

        program
            .request()
            .accounts(voter_registration_accounts::Initialize {
                registration,
                admin: program.payer(),
                system_program: anchor_lang::system_program::ID,
            })
            .args(voter_registration_instruction::Initialize {})
            .send()
    })
        .await
        .unwrap();

    match result {
        Ok(_) => {
            res.render(Json(ApiResponse {
                success: true,
                message: "Registration initialized successfully".to_string(),
            }));
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to initialize registration: {}", e),
            }));
        }
    }
}

#[handler]
pub async fn finalize_registration(res: &mut Response) {
    let result = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voter_registration::ID).unwrap();
        let (registration, _) = Pubkey::find_program_address(&[b"registration"], &program.id());

        program
            .request()
            .accounts(voter_registration_accounts::FinalizeRegistration {
                registration,
                admin: program.payer(),
            })
            .args(voter_registration_instruction::FinalizeRegistration {})
            .send()
    })
        .await
        .unwrap();

    match result {
        Ok(_) => {
            res.render(Json(ApiResponse {
                success: true,
                message: "Registration finalized successfully".to_string(),
            }));
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to finalize registration: {}", e),
            }));
        }
    }
}