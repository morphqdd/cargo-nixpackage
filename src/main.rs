use crate::cli::Cli;
use clap::Parser;

mod cli;
mod template;

fn main() -> anyhow::Result<()> {
    Cli::parse().execute()
}
