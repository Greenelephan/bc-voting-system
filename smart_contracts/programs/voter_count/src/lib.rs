use anchor_lang::prelude::*;
use crate::state::VoterCount;

pub mod errors;
pub mod instructions;
pub mod state;

declare_id!("C3kxkJQa5WoFmW4njxhvEV6THT6m68AEBGyn4jVZJsbd");

#[program]
pub mod voter_count {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, total_voters: u32) -> Result<()> {
        instructions::initialize(ctx, total_voters)
    }

    pub fn increment(ctx: Context<Increment>) -> Result<()> {
        instructions::increment(ctx)
    }

    pub fn finalize(ctx: Context<Finalize>) -> Result<()> {
        instructions::finalize(ctx)
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = admin, space = 8 + VoterCount::MAX_SIZE)]
    pub voter_count: Account<'info, VoterCount>,
    #[account(mut)]
    pub admin: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Increment<'info> {
    #[account(mut)]
    pub voter_count: Account<'info, VoterCount>,
}

#[derive(Accounts)]
pub struct Finalize<'info> {
    #[account(mut, has_one = admin)]
    pub voter_count: Account<'info, VoterCount>,
    pub admin: Signer<'info>,
}