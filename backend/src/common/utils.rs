use base64::{Engine as _, engine::general_purpose};
use rand::Rng;
use sha2::{Sha256, Digest};

pub fn generate_receipt_id(voting_id: &str, timestamp: &str) -> String {
    let mut rng = rand::thread_rng();
    let random_bytes: [u8; 8] = rng.gen();

    let mut hasher = Sha256::new();
    hasher.update(voting_id);
    hasher.update(timestamp);
    hasher.update(&random_bytes);
    let result = hasher.finalize();

    let encoded = general_purpose::URL_SAFE_NO_PAD.encode(&result[..16]);
    format!("{}-{}", voting_id, encoded)
}

pub fn extract_voting_id(receipt_id: &str) -> Result<String, String> {
    receipt_id
        .split('-')
        .next()
        .map(|s| s.to_string())
        .ok_or_else(|| "Invalid receipt ID format".to_string())
}