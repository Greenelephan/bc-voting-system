pub mod auth;
pub mod common;
pub mod smart_contracts;
mod routes;

use salvo::cors::Cors;
use salvo::http::Method;
use salvo::prelude::*;
use crate::smart_contracts::voter_registration::handlers::{
    initialize_registration,
    finalize_registration,
    register_voter,
    registration_status
};
use crate::smart_contracts::voting_system::handlers::{initialize_voting, finalize_voting, voting_statistic, voting_status, voting_info, open_votings};
use crate::smart_contracts::voter::handlers::{voter_status, cast_vote, vote_status};
use crate::auth::handlers::login;
use crate::routes::{admin_route, public_route, voter_route};

#[tokio::main]
async fn main() {
    let cors = Cors::new()
        .allow_origin("http://localhost:4040")
        .allow_credentials(true)
        .allow_methods(vec![Method::GET, Method::POST, Method::OPTIONS])
        .allow_headers(vec!["Content-Type", "Authorization"])
        .max_age(3600)
        .into_handler();

    let router = Router::new()
        .push(public_route().path("api/auth/login").post(login))
        .push(public_route()
            .path("api/voting")
            .push(Router::with_path("status/<votingId>").get(voting_status))
            .push(Router::with_path("info/<votingId>").get(voting_info))
            .push(Router::with_path("open").get(open_votings)))
        .push(voter_route()
            .path("api/voters")
            .push(Router::with_path("vote").post(cast_vote))
            .push(Router::with_path("register").post(register_voter))
            .push(Router::with_path("<voterId>/votes/<receiptId>").get(vote_status))
            .push(Router::with_path("<voterId>/status").get(voter_status)))
        .push(admin_route()
            .path("api/admin")
            .push(Router::with_path("registration")
                .push(Router::with_path("initialize").post(initialize_registration))
                .push(Router::with_path("status").get(registration_status))
                .push(Router::with_path("finalize").post(finalize_registration)))
            .push(Router::with_path("voting")
                .push(Router::with_path("initialize").post(initialize_voting))
                .push(Router::with_path("statistics").get(voting_statistic))
                .push(Router::with_path("finalize/<votingId>").post(finalize_voting)))
        );

    let service = Service::new(router).hoop(cors);
    let acceptor = TcpListener::new("127.0.0.1:8080").bind().await;
    println!("Server running on 127.0.0.1:8080");
    Server::new(acceptor).serve(service).await;
}
