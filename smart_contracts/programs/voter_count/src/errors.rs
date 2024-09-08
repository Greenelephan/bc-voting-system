use anchor_lang::prelude::*;

#[error_code]
pub enum VoterCountError {
    #[msg("Voting has already ended.")]
    VotingEnded,
}