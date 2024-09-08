use anchor_lang::prelude::*;

#[error_code]
pub enum RegistrationError {
    #[msg("Registration is already initialized")]
    AlreadyInitialized,
    #[msg("Registration is closed")]
    RegistrationClosed,
    #[msg("Voter is already registered")]
    AlreadyRegistered,
    #[msg("Registration is already finalized")]
    AlreadyFinalized,
}