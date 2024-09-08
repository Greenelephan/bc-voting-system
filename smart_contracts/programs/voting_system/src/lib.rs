pub mod errors;
pub mod instructions;
pub mod state;

use instructions::*;
use anchor_lang::prelude::*;
use crate::state::Candidate;

declare_id!("7mq1XuSQtpsi2sAWR9hEoYySGDQ9KprgxiUSNXsNjpvq");

#[program]
pub mod voting_system {
    use super::*;

    pub fn initialize_voting(ctx: Context<InitializeVoting>, candidates: Vec<Candidate>) -> Result<()> {
        instructions::initialize_voting(ctx, candidates)
    }

    pub fn cast_vote(ctx: Context<CastVote>, candidate_id: u64) -> Result<()> {
        instructions::cast_vote(ctx, candidate_id)
    }

    pub fn finalize_voting(ctx: Context<FinalizeVoting>) -> Result<()> {
        instructions::finalize_voting(ctx)
    }
}