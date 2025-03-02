use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Copy, PartialEq, Eq)]
#[serde(rename_all = "lowercase")]
pub enum VotingStatus {
    Open,
    NotStarted,
    Registration,
    Voting,
    Closed,
}

pub struct VotingStateInfo {
    pub is_voting_open: bool,
    pub is_registration_open: bool,
}

impl VotingStatus {
    pub fn from_voting_state(state: &VotingStateInfo) -> Self {
        if !state.is_voting_open {
            VotingStatus::Closed
        } else if state.is_registration_open {
            VotingStatus::Registration
        } else {
            VotingStatus::Voting
        }
    }
}
#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InitializeVotingRequest {
    pub title: String,
    pub candidates: Vec<CandidateRequest>,
}

#[derive(Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CandidateRequest {
    pub name: String,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct CandidateResponse {
    pub id: u64,
    pub name: String,
    pub votes: u64,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VotingStatusResponse {
    pub voting_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub status: Option<VotingStatus>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub title: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub candidates: Option<Vec<CandidateResponse>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub candidates_count: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub total_votes: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub total_registered_voters: Option<u64>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub timestamp: Option<String>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct OpenVotingsResponse {
    pub(crate) open_votings: Vec<VotingStatusResponse>,
}
