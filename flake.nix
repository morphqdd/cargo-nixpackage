{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let 
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      rustSource = pkgs.lib.cleanSourceWith {
        src = ./.;
        filter = name: type: !builtins.elem (baseNameOf name) [ "./target" ".git" ];
      };

      manifestPath = "${toString rustSource}/Cargo.toml";
      manifest = builtins.fromTOML ( builtins.readFile manifestPath );

      cargoRun = pkgs.writeShellScriptBin "cargo-run" ''
        export CARGO_TARGET_DIR=./target
        exec ${pkgs.cargo}/bin/cargo run --target x86_64-unknown-linux-gnu --manifest-path ./Cargo.toml "$@"
      '';

      cargoCheck = pkgs.writeShellScriptBin "cargo-check" ''
        export CARGO_TARGET_DIR=./target
        exec ${pkgs.cargo}/bin/cargo check --manifest-path ./Cargo.toml "$@"
      '';

      cargoClippy = pkgs.writeShellScriptBin "cargo-clippy" ''
        export CARGO_TARGET_DIR=./target
        exec ${pkgs.cargo}/bin/cargo clippy --manifest-path ./Cargo.toml "$@"
      '';

    in {
      packages."${system}".default = pkgs.rustPlatform.buildRustPackage rec {
        pname = manifest.package.name;
        version = manifest.package.version;
        src = rustSource;
        cargoLock.lockFile = "${src}/Cargo.lock";
      };

      devShells."${system}".default = pkgs.mkShell {
        buildInputs = with pkgs; [
          rustc 
          cargo
          rustfmt
          clippy
          fish
        ];
        shellHook = ''
          export SHELL="${pkgs.fish}/bin/fish"
          echo $SHELL
        '';
      };

      apps."${system}" = {
        default = {
          type = "app";
          program = (cargoRun) + "/bin/cargo-run";
        };

        check = {
          type = "app";
          program = (cargoCheck) + "/bin/cargo-check";
        };

        clippy = {
          type = "app";
          program = (cargoClippy) + "/bin/cargo-clippy";
        };
      };
    };
}
