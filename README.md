# cargo-nixpackage

📦 A small utility to scaffold Rust projects with Nix Flake support.

`cargo-nixpackage` helps you quickly set up a Rust project using `nix`, automatically generating a `flake.nix`, initializing a Git repository, and creating wrapper scripts for Cargo commands inside a reproducible development environment.

---

## ✨ Features

- Generates a minimal `flake.nix` for your Rust project
- Sets up a development shell with `rustc`, `cargo`, `rustfmt`, `clippy`, and `fish`
- Provides simple wrappers for:
  - `cargo init`
  - `cargo run`
  - `cargo check`
  - `cargo clippy`
- Customizable target system (defaults to `x86_64-linux`)
- Git repository auto-initialization

---

## 🧪 Usage
### Create a new project
```bash
cargo nixpackage new my_project --system x86_64-linux
cd my_project
nix develop
```
