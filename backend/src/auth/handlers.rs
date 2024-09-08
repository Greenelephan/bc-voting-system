use salvo::{handler, Request, Response};
use salvo::http::StatusCode;
use salvo::prelude::Json;
use crate::models::models::{LoginRequest, LoginResponse};
use crate::auth::jwt::create_jwt;

#[handler]
pub async fn login(req: &mut Request, res: &mut Response) {
    let login_req: LoginRequest = match req.parse_json().await {
        Ok(req) => req,
        Err(e) => {
            res.status_code(StatusCode::BAD_REQUEST);
            res.render(Json(
                serde_json::json!({ "error": format!("Invalid request: {}", e) }),
            ));
            return;
        }
    };

    let role = if login_req.user_id == "admin" {
        "admin"
    } else {
        "voter"
    };

    match create_jwt(&login_req.user_id, role) {
        Ok(token) => {
            res.render(Json(LoginResponse {
                token,
                role: role.to_string(),
            }));
        }
        Err(e) => {
            res.status_code(StatusCode::INTERNAL_SERVER_ERROR);
            res.render(Json(
                serde_json::json!({ "error": format!("Failed to create token: {}", e) }),
            ));
        }
    }
}