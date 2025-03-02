use anchor_client::anchor_lang;
use anchor_client::anchor_lang::prelude::*;
use chrono::Utc;
use salvo::{handler, Depot, Response};
use salvo::http::StatusCode;
use salvo::prelude::Json;
use voting_system::accounts as voting_system_accounts;
use voting_system::instruction as voting_system_instructions;
use voting_system::states::Registration;
use crate::common::models::{ApiResponse, Claims};
use crate::smart_contracts::solana::create_anchor_client;
use crate::smart_contracts::voter_registration::models::{
    RegistrationStatusResponse,
    VoterRegistrationResponse};

#[handler]
pub async fn register_voter(depot: &mut Depot, res: &mut Response) {
    let claims = depot.get::<Claims>("user_claims").unwrap();
    let voter_id = claims.sub.clone();

    let result = tokio::task::spawn_blocking({
        let voter_id_clone = voter_id.clone();

        move || {
            let client = create_anchor_client();
            let program = client.program(voting_system::ID).unwrap();
            let admin_pubkey = program.payer();

            // Check registration status first
            let (registration, _) = Pubkey::find_program_address(&[b"registration"], &program.id());

            // Try to get registration account
            let registration_result = program.account::<Registration>(registration);

            // If registration doesn't exist, initialize it
            if registration_result.is_err() {
                program
                    .request()
                    .accounts(voting_system_accounts::InitializeRegistration {
                        registration,
                        admin: admin_pubkey,
                        system_program: anchor_lang::system_program::ID,
                    })
                    .args(voting_system_instructions::InitializeRegistration {})
                    .send()?;
            }

            // Get registration status after potential initialization
            let registration_account: Registration = program.account(registration)?;
            if !registration_account.is_open {
                return Err(anyhow::anyhow!("Registration is currently closed"));
            }

            // Generate the voter account PDA
            let (voter_account, _) = Pubkey::find_program_address(
                &[b"voter", admin_pubkey.as_ref(), voter_id_clone.as_bytes()],
                &program.id(),
            );

            // Register voter
            program
                .request()
                .accounts(voting_system_accounts::RegisterVoter {
                    registration,
                    voter: voter_account,
                    admin: admin_pubkey,
                    system_program: anchor_lang::system_program::ID,
                })
                .args(voting_system_instructions::RegisterVoter { voter_id: voter_id_clone })
                .send()
                .unwrap();

            Ok(voter_account.to_string())
        }
    })
    .await;

    match result {
        Ok(Ok(registration_token)) => {
            res.render(Json(VoterRegistrationResponse {
                voter_id,
                registration_token,
                timestamp: Utc::now().to_rfc3339(),
            }));
        }
        Ok(Err(e)) => {
            println!("Registration error: {:?}", e);
            res.status_code(StatusCode::BAD_REQUEST);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Registration failed: {}", e),
            }));
        }
        Err(e) => {
            println!("Task execution error: {:?}", e);
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Task execution failed: {}", e),
            }));
        }
    }
}

#[handler]
pub async fn initialize_registration(res: &mut Response) {
    let result = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (registration, _) = Pubkey::find_program_address(&[b"registration"], &program.id());

        program
            .request()
            .accounts(voting_system_accounts::InitializeRegistration {
                registration,
                admin: program.payer(),
                system_program: anchor_lang::system_program::ID,
            })
            .args(voting_system_instructions::InitializeRegistration {})
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
        let program = client.program(voting_system::ID).unwrap();
        let (registration, _) = Pubkey::find_program_address(&[b"registration"], &program.id());

        program
            .request()
            .accounts(voting_system_accounts::FinalizeRegistration {
                registration,
                admin: program.payer(),
            })
            .args(voting_system_instructions::FinalizeRegistration {})
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

#[handler]
pub async fn registration_status(res: &mut Response) {
    let result: Result<RegistrationStatusResponse> = tokio::task::spawn_blocking(move || {
        let client = create_anchor_client();
        let program = client.program(voting_system::ID).unwrap();
        let (registration_account, _) = Pubkey::find_program_address(&[b"registration"], &program.id());

        let registration: Registration = program.account(registration_account).unwrap();
        Ok(RegistrationStatusResponse {
            status: if registration.is_open {"open"} else {"closed"}.to_string(),
            voter_count: registration.voter_count,
            timestamp: Utc::now().to_rfc3339(),
        })
    })
        .await
        .unwrap();

    match result {
        Ok(status) => {
            res.render(Json(status));
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(ApiResponse {
                success: false,
                message: format!("Failed to get registration status: {}", e),
            }));
        }
    }
}
