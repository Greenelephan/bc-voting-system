use std::sync::Arc;
use anchor_client::{Client, Cluster};
use anchor_client::solana_sdk::commitment_config::CommitmentConfig;
use anchor_client::solana_sdk::signature::{read_keypair_file, Keypair};

pub fn create_anchor_client() -> Client<Arc<Keypair>> {
    let payer = read_keypair_file(&*shellexpand::tilde("~/.config/solana/new_id.json"))
        .expect("Failed to read keypair file");
    let url = Cluster::Custom(
        "http://localhost:8899".to_string(),
        "ws://127.0.0.1:8900".to_string(),
    );
    Client::new_with_options(url, Arc::new(payer), CommitmentConfig::processed())
}