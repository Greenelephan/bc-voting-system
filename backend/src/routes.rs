use salvo::prelude::*;
use crate::auth::middleware::auth;

pub fn public_route() -> Router {
    Router::new()
}

pub fn voter_route() -> Router {
    Router::new().hoop(auth(vec!["voter".to_string()]))
}

pub fn admin_route() -> Router {
    Router::new().hoop(auth(vec!["admin".to_string()]))
}
