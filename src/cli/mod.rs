use std::{
    env,
    fs::File,
    io::Write,
    path::{Path, PathBuf},
    process::Command,
};

use clap::{Parser, Subcommand};
use tera::{Context, Tera};

use crate::template::FLAKE_TEMPLATE;

#[derive(Parser, Debug, Clone)]
pub struct Cli {
    #[command(subcommand)]
    subcommand: CliSubcommand,
}

impl Cli {
    pub fn execute(&self) -> anyhow::Result<()> {
        match &self.subcommand {
            CliSubcommand::New { path, system } => self.new_project(path, system),
            CliSubcommand::Init { system } => self.new_project(env::current_dir().unwrap(), system),
        }
    }

    pub fn new_project<P: AsRef<Path>>(&self, path: P, system: &str) -> anyhow::Result<()> {
        let mut tera = Tera::default();
        tera.add_raw_template("flake", FLAKE_TEMPLATE)?;

        let mut ctx = Context::new();
        ctx.insert("system", system);

        let render = tera.render("flake", &ctx)?;

        if !path.as_ref().exists() {
            std::fs::create_dir_all(&path)?;
        }

        File::create(path.as_ref().join("flake.nix"))?.write_all(render.as_bytes())?;

        env::set_current_dir(path.as_ref())?;

        if Command::new("git")
            .args(["init", "./."])
            .spawn()?
            .wait()
            .is_ok()
            && Command::new("git")
                .args(["add", "./."])
                .spawn()?
                .wait()
                .is_ok()
            && Command::new("nix")
                .args([ "develop", "--command", "nix", "run", ".#init" ]).spawn()?.wait().is_ok()
        {
            Command::new("echo").arg("Done").spawn()?;
        }

        Ok(())
    }
}

#[derive(Debug, Clone, Subcommand)]
pub enum CliSubcommand {
    New {
        path: PathBuf,
        #[arg(short, default_value = "x86_64-linux")]
        system: String,
    },
    Init {
        #[arg(short, default_value = "x86_64-linux")]
        system: String,
    },
}
