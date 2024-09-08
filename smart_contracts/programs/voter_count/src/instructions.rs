use anchor_lang::prelude::*;
use crate::errors::VoterCountError;
use crate::Finalize;
use crate::Increment;
use crate::Initialize;

pub fn initialize(ctx: Context<Initialize>, total_voters: u32) -> Result<()> {
    let voter_count = &mut ctx.accounts.voter_count;
    voter_count.total_voters = total_voters;
    voter_count.current_count = 0;
    voter_count.ended = false;
    Ok(())
}

pub fn increment(ctx: Context<Increment>) -> Result<()> {
    let voter_count = &mut ctx.accounts.voter_count;

    if voter_count.ended {
        return Err(VoterCountError::VotingEnded.into());
    }

    voter_count.current_count += 1;
    Ok(())
}

pub fn finalize(ctx: Context<Finalize>) -> Result<()> {
    let voter_count = &mut ctx.accounts.voter_count;
    voter_count.ended = true;
    Ok(())
}