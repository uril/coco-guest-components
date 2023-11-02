// Copyright (c) 2023 by Alibaba.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

//! A simple KBS client for test.

use anyhow::{bail, Result};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use clap::{Parser, Subcommand};
use std::path::PathBuf;

#[derive(Parser)]
#[clap(name = "AA client")]
#[clap(author, version, about = "A simple program to get a key from KBS", long_about = None)]
struct Cli {
    #[clap(subcommand)]
    command: Commands,

    /// The KBS server root URL.
    #[clap(long, value_parser)]
    url: String,

    /// The KBS HTTPS server custom root certificate file path (PEM format)
    #[clap(long, value_parser)]
    cert_file: Option<PathBuf>,
}

#[derive(Subcommand)]
enum Commands {
    /// Get confidential resource
    #[clap(arg_required_else_help = true)]
    GetResource {
        /// KBS Resource path, e.g my_repo/resource_type/123abc
        /// Document: https://github.com/confidential-containers/attestation-agent/blob/main/docs/KBS_URI.md
        #[clap(long, value_parser)]
        resource_path: String,

        /// Custom TEE private Key (RSA) file path (PEM format)
        /// Used to protect the Respond Payload
        ///
        /// If NOT set this argument,
        /// KBS client will generate a new TEE Key pair internally.
        #[clap(long, value_parser)]
        tee_key_file: Option<PathBuf>,

        /// Attestation Token file path
        ///
        /// If set this argument, `--tee_key_file` argument should also be set,
        /// and the public part of TEE Key should be consistent with tee-pubkey in the token.
        #[clap(long, value_parser)]
        attestation_token: Option<PathBuf>,
    },

    /// Attestation and get attestation results token
    Attest {
        /// Custom TEE private Key (RSA) file path (PEM format)
        /// The public part of this key will be included in the token obtained by attestation.
        ///
        /// If not set this argument,
        /// KBS client will generate a new TEE Key pair internally.
        #[clap(long, value_parser)]
        tee_key_file: Option<PathBuf>,
    },
}

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let cli = Cli::parse();

    let kbs_cert = match cli.cert_file {
        Some(p) => vec![std::fs::read_to_string(p)?],
        None => vec![],
    };

    match cli.command {
        Commands::Attest { tee_key_file } => {
            let tee_key = match tee_key_file {
                Some(f) => Some(std::fs::read_to_string(f)?),
                None => None,
            };
            let token = aa_client::attestation(&cli.url, tee_key, kbs_cert.clone()).await?;
            println!("{token}");
        }
        Commands::GetResource {
            resource_path,
            tee_key_file,
            attestation_token,
        } => {
            let tee_key = match tee_key_file {
                Some(f) => Some(std::fs::read_to_string(f)?),
                None => None,
            };
            let token = match attestation_token {
                Some(t) => Some(std::fs::read_to_string(t)?.trim().to_string()),
                None => None,
            };

            if token.is_some() {
                if tee_key.is_none() {
                    bail!("if `--attestation-token` is set, `--tee_key_file` argument should also be set, and the public part of TEE Key should be consistent with tee-pubkey in the token.");
                }
                let resource_bytes = aa_client::get_resource_with_token(
                    &cli.url,
                    &resource_path,
                    tee_key.unwrap(),
                    token.unwrap(),
                    kbs_cert.clone(),
                )
                .await?;
                println!("{}", STANDARD.encode(resource_bytes));
            } else {
                let resource_bytes = aa_client::get_resource_with_attestation(
                    &cli.url,
                    &resource_path,
                    tee_key,
                    kbs_cert.clone(),
                )
                .await?;
                println!("{}", STANDARD.encode(resource_bytes));
            }
        }
    }

    Ok(())
}
