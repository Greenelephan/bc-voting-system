use anchor_lang::prelude::*;
use crate::state::*;
use crate::errors::RegistrationError;

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = admin,
        space = 8 + Registration::MAX_SIZE,
        seeds = [b"registration"],
        bump
    )]
    pub registration: Account<'info, Registration>,
    #[account(mut)]
    pub admin: Signer<'info>,
    pub system_program: Program<'info, System>,
}

pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
    let registration = &mut ctx.accounts.registration;
    registration.admin = ctx.accounts.admin.key();
    registration.is_open = true;
    registration.voter_count = 0;
    Ok(())
}

#[derive(Accounts)]
#[instruction(voter_id: String)]
pub struct RegisterVoter<'info> {
    #[account(mut)]
    pub registration: Account<'info, Registration>,
    #[account(
        init,
        payer = user,
        space = 8 + Voter::MAX_SIZE,
        seeds = [b"voter", user.key().as_ref(), voter_id.as_bytes()],
        bump
    )]
    pub voter: Account<'info, Voter>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

pub fn register_voter(ctx: Context<RegisterVoter>, voter_id: String) -> Result<()> {
    let registration = &mut ctx.accounts.registration;
    let voter = &mut ctx.accounts.voter;

    require!(registration.is_open, RegistrationError::RegistrationClosed);
    require!(!voter.is_registered, RegistrationError::AlreadyRegistered);

    voter.id = voter_id;
    voter.is_registered = true;
    voter.has_voted = false;
    registration.voter_count += 1;
    Ok(())
}

#[derive(Accounts)]
pub struct FinalizeRegistration<'info> {
    #[account(mut, seeds = [b"registration"], bump, has_one = admin)]
    pub registration: Account<'info, Registration>,
    pub admin: Signer<'info>,
}

pub fn finalize_registration(ctx: Context<FinalizeRegistration>) -> Result<()> {
    let registration = &mut ctx.accounts.registration;
    require!(registration.is_open, RegistrationError::AlreadyFinalized);
    registration.is_open = false;
    Ok(())
}