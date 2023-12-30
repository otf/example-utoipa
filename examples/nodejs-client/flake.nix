{
  description = "NodeJS development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f rec {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    packages = forAllSystems ({
      pkgs,
      ...
    }: {
      default = 
        let
          index = pkgs.writeText "index.mjs" (builtins.readFile ./index.mjs);
        in pkgs.writeShellApplication {
          name = "nodejs-client";
          runtimeInputs = [
            pkgs.nodejs_21
          ];
          text = ''
            node --test ${index}
          '';
        };
    });

    devShells = forAllSystems ({
      pkgs,
      ...
    }:
      with pkgs; {
        default = mkShell {
          buildInputs = [
            nodejs_21
            nodePackages.npm
            nodePackages.typescript-language-server
          ];
        };
      });

    checks = forAllSystems ({...}: { });

    formatter = forAllSystems ({pkgs, ...}: pkgs.nodePackages.typescript-language-server);
  };
}
