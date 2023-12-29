{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    naersk.url = "github:nix-community/naersk/master";
    nix-pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    naersk,
    nix-pre-commit-hooks,
  }: let
    supportedSystems = ["aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f rec {
          pkgs = import nixpkgs {inherit system;};
          naersk-lib = pkgs.callPackage naersk {};
          pre-commit-check = nix-pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              rustfmt.enable = true;
              clippy.enable = true;
            };
          };
        });
  in {
    packages = forAllSystems ({
      pkgs,
      naersk-lib,
      ...
    }: {
      default = naersk-lib.buildPackage {
        src = ./.;
      };
    });

    devShells = forAllSystems ({
      pkgs,
      pre-commit-check,
      ...
    }:
      with pkgs; {
        default = mkShell {
          buildInputs = [
            cargo
            rustc
            rustfmt
            pre-commit
            rustPackages.clippy
            rust-analyzer
          ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          shellHook = ''
            ${pre-commit-check.shellHook}
          '';
        };
      });

    checks = forAllSystems ({pre-commit-check, ...}: {
      inherit pre-commit-check;
    });

    formatter = forAllSystems ({pkgs, ...}: pkgs.rustfmt);
  };
}
