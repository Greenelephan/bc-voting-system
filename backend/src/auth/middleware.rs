use salvo::prelude::*;
use crate::auth::jwt::validate_jwt;

#[derive(Clone)]
pub struct AuthMiddleware {
    pub required_roles: Vec<String>,
}

#[async_trait]
impl Handler for AuthMiddleware {
    async fn handle(&self, req: &mut Request, depot: &mut Depot, res: &mut Response, ctrl: &mut FlowCtrl) {
        let token = req.headers()
            .get("Authorization")
            .and_then(|value| value.to_str().ok())
            .and_then(|auth_str| auth_str.strip_prefix("Bearer "))
            .unwrap_or("");

        match validate_jwt(token) {
            Ok(claims) => {
                if self.required_roles.is_empty() || self.required_roles.contains(&claims.role) {
                    depot.insert("user_claims", claims);
                } else {
                    res.status_code(StatusCode::FORBIDDEN);
                    res.render(Json(serde_json::json!({"error": "Access denied"})));
                    ctrl.skip_rest();
                }
            }
            Err(_) => {
                res.status_code(StatusCode::UNAUTHORIZED);
                res.render(Json(serde_json::json!({"error": "Invalid token"})));
                ctrl.skip_rest();
            }
        }
    }
}

pub fn auth(required_roles: Vec<String>) -> AuthMiddleware {
    AuthMiddleware { required_roles }
}