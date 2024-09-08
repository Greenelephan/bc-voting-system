use anchor_lang::prelude::*;
use serde::{Serialize, Deserialize};
#[derive(AnchorSerialize, AnchorDeserialize, Clone, Default, Serialize, Deserialize)]
pub struct Candidate {
    pub name: String,
}

#[account]
pub struct Voting {
    pub admin: Pubkey,
    pub is_open: bool,
    pub total_votes: u64,
    pub candidates: Vec<Candidate>,
    pub votes: Vec<u64>,
}

impl Voting {
    pub const MAX_SIZE: usize = 32 + 1 + 8 + 4 + (4 + 32) * 10 + 4 + 8 * 10; // Assuming max 10 candidates
}

#[account]
pub struct Voter {
    pub id: String,
    pub is_registered: bool,
    pub has_voted: bool,
}

impl Voter {
    pub const MAX_SIZE: usize = 4 + 64 + 1;
}