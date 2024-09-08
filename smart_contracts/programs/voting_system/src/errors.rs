use anchor_lang::prelude::*;

#[error_code]
pub enum VotingError {
    #[msg("Voting is already initialized")]
    AlreadyInitialized,
    #[msg("Insufficient number of candidates")]
    InsufficientCandidates,
    #[msg("Voting is closed")]
    VotingClosed,
    #[msg("Voter is not registered")]
    VoterNotRegistered,
    #[msg("Voter has already voted")]
    AlreadyVoted,
    #[msg("Invalid candidate ID")]
    InvalidCandidate,
    #[msg("Voting is already finalized")]
    AlreadyFinalized,
}