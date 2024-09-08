use anchor_lang::prelude::*;
use crate::state::*;
use crate::errors::VotingError;

#[derive(Accounts)]
pub struct InitializeVoting<'info> {
    #[account(
        init,
        payer = admin,
        space = 8 + Voting::MAX_SIZE,
        seeds = [b"voting"],
        bump
    )]
    pub voting: Account<'info, Voting>,
    #[account(mut)]
    pub admin: Signer<'info>,
    pub system_program: Program<'info, System>,
}

pub fn initialize_voting(ctx: Context<InitializeVoting>, candidates: Vec<Candidate>) -> Result<()> {
    require!(candidates.len() > 1, VotingError::InsufficientCandidates);

    let voting = &mut ctx.accounts.voting;
    voting.admin = ctx.accounts.admin.key();
    voting.is_open = true;
    voting.total_votes = 0;
    voting.candidates = candidates;
    voting.votes = vec![0; voting.candidates.len()];
    Ok(())
}

#[derive(Accounts)]
pub struct CastVote<'info> {
    #[account(mut, seeds = [b"voting"], bump)]
    pub voting: Account<'info, Voting>,
    #[account(mut, seeds = [b"voter", voter.key().as_ref()], bump)]
    pub voter: Account<'info, Voter>,
    pub user: Signer<'info>,
}

pub fn cast_vote(ctx: Context<CastVote>, candidate_id: u64) -> Result<()> {
    let voting = &mut ctx.accounts.voting;
    let voter = &mut ctx.accounts.voter;

    require!(voting.is_open, VotingError::VotingClosed);
    require!(voter.is_registered, VotingError::VoterNotRegistered);
    require!(!voter.has_voted, VotingError::AlreadyVoted);
    require!((candidate_id as usize) < voting.candidates.len(), VotingError::InvalidCandidate);

    voting.votes[candidate_id as usize] += 1;
    voting.total_votes += 1;
    voter.has_voted = true;
    Ok(())
}

#[derive(Accounts)]
pub struct FinalizeVoting<'info> {
    #[account(mut, seeds = [b"voting"], bump, has_one = admin)]
    pub voting: Account<'info, Voting>,
    pub admin: Signer<'info>,
}

pub fn finalize_voting(ctx: Context<FinalizeVoting>) -> Result<()> {
    let voting = &mut ctx.accounts.voting;
    require!(voting.is_open, VotingError::AlreadyFinalized);
    voting.is_open = false;
    Ok(())
}