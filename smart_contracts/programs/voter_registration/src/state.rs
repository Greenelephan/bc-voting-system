use anchor_lang::prelude::*;

#[account]
pub struct Registration {
    pub admin: Pubkey,
    pub is_open: bool,
    pub voter_count: u64,
}

impl Registration {
    pub const MAX_SIZE: usize = 32 + 1 + 8;
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