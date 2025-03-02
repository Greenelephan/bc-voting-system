use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Copy, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum VoteStatus {
    COUNTED,
    PENDING,
    REJECTED,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VoterStatusResponse {
    pub voter_id: String,
    pub is_registered: bool,
    pub has_voted: bool,
    pub timestamp: String,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CastVoteResponse {
    pub success: bool,
    pub receipt_id: String,
    pub timestamp: String,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CastVoteRequest {
    pub voting_id: String,
    pub candidate_id: u64,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VoteStatusResponse {
    pub status: VoteStatus,
    pub timestamp: String,
}
