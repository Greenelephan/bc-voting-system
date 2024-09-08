use anchor_lang::prelude::*;

#[account]
pub struct VoterCount {
    pub admin: Pubkey,
    pub total_voters: u32,
    pub current_count: u32,
    pub ended: bool,
}

impl VoterCount {
    // Calculate the maximum size of the VoterCount account
    pub const MAX_SIZE: usize = 8; // Adjust this size as necessary
}