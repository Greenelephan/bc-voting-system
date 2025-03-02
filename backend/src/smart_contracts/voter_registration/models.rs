use serde::Serialize;

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct VoterRegistrationResponse {
    pub voter_id: String,
    pub registration_token: String,
    pub timestamp: String,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
pub struct RegistrationStatusResponse {
    pub status: String,
    pub(crate) voter_count: u64,
    pub timestamp: String,
}