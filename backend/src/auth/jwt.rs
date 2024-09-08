use chrono::{Duration, Utc};
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Header, Validation};
use crate::models::models::Claims;

pub fn create_jwt(user_id: &str, role: &str) -> anyhow::Result<String> {
    let expiration = Utc::now()
        .checked_add_signed(Duration::hours(1))
        .expect("valid timestamp")
        .timestamp();

    let claims = Claims {
        sub: user_id.to_owned(),
        role: role.to_owned(),
        exp: expiration as usize,
    };

    let header = Header::new(Algorithm::HS256);
    encode(
        &header,
        &claims,
        &EncodingKey::from_secret("secret".as_ref()),
    )
        .map_err(|e| anyhow::anyhow!("Error creating JWT: {}", e))
}

pub fn validate_jwt(token: &str) -> anyhow::Result<Claims, jsonwebtoken::errors::Error> {
    let validation = Validation::new(Algorithm::HS256);
    let token_data = decode::<Claims>(
        token,
        &DecodingKey::from_secret("secret".as_ref()),
        &validation,
    )?;
    Ok(token_data.claims)
}