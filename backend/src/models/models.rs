use serde::{Deserialize, Serialize};
use voting_system::state::Candidate;

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String,
    pub role: String,
    pub exp: usize,
}

#[derive(Deserialize)]
pub struct LoginRequest {
    pub user_id: String,
    pub password: String,
}

#[derive(Serialize)]
pub struct LoginResponse {
    pub token: String,
    pub role: String,
}

#[derive(Serialize)]
pub struct VoterRegistrationResponse {
    pub voter_id: String,
    pub registration_token: String,
    pub timestamp: String,
}

#[derive(Serialize)]
pub struct ApiResponse {
    pub success: bool,
    pub message: String,
}

#[derive(Deserialize)]
pub struct InitializeVotingRequest {
    pub title: String,
    pub candidates: Vec<Candidate>,
}

#[derive(Deserialize)]
pub struct CastVoteRequest {
    pub voting_token: String,
    pub candidate_id: u64,
}

#[derive(Serialize)]
pub struct VotingResponse {
    pub voting_id: String,
    pub status: String,
    pub candidates: Vec<serde_json::Value>,
    pub timestamp: String,
}