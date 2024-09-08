use anchor_lang::prelude::*;

pub mod errors;
pub mod instructions;
pub mod state;

use instructions::*;

declare_id!("5xTrnDs8kmZKQ167N9P7UpauYRjVmHJorEecQonadHf3");

#[program]
pub mod voter_registration {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        instructions::initialize(ctx)
    }

    pub fn register_voter(ctx: Context<RegisterVoter>, voter_id: String) -> Result<()> {
        instructions::register_voter(ctx, voter_id)
    }

    pub fn finalize_registration(ctx: Context<FinalizeRegistration>) -> Result<()> {
        instructions::finalize_registration(ctx)
    }
}
