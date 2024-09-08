pub mod auth;
pub mod models;
pub mod smart_contracts;

use salvo::prelude::*;
use crate::smart_contracts::voter_registration::handlers::{
    initialize_registration,
    finalize_registration,
    register_voter};
use crate::smart_contracts::voting_system::handlers::{
  initialize_voting,
  cast_vote,
  finalize_voting
};
use crate::auth::handlers::login;

#[tokio::main]
async fn main() {
    let router = Router::new()
        .push(Router::with_path("api/auth/login").post(login))
        .push(Router::with_path("api/voters/register").post(register_voter))
        .push(Router::with_path("api/admin/registration/initialize").post(initialize_registration))
        .push(Router::with_path("api/admin/registration/finalize").post(finalize_registration))
        .push(Router::with_path("api/admin/voting/initialize").post(initialize_voting))
        .push(Router::with_path("api/votes").post(cast_vote))
        .push(Router::with_path("api/admin/voting/finalize").post(finalize_voting));

    let acceptor = TcpListener::new("127.0.0.1:8080").bind().await;
    println!("Server running on 127.0.0.1:8080");
    Server::new(acceptor).serve(router).await;
}
