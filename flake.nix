{
  description = "NVIM debugging suite for MDx07";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    mdx07-templates = {
      url = "git+https://git.chalmers.se/haelias/mdx07-templates-library.git";
      flake = false;
    };
    mdx07-binaries = {
      url = "git+https://git.chalmers.se/erik.sintorn/mdx07-binaries.git";
      flake = false;
    };
    riscv-gcc = {
      url = "https://www.cse.chalmers.se/edu/resources/software/riscv32-gcc/riscv-gcc-ubuntu-22.04-x64.tar.gz";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      perSystem =
        { pkgs, system, ... }:
        rec {
          packages = {
            mdx07-tools = pkgs.callPackage ./mdx07-tools.nix { inherit (inputs) mdx07-binaries; };

            mdx07-init = pkgs.callPackage ./mdx07-init.nix { inherit (packages) mdx07-templates; };

            mdx07-templates = pkgs.callPackage ./mdx07-templates.nix { inherit (inputs) mdx07-templates; };

            mdx07-riscv-gcc = pkgs.callPackage ./mdx07-riscv-gcc.nix { inherit (inputs) riscv-gcc; };

            mdx07-nvim = pkgs.callPackage ./mdx07-nvim.nix {
              inherit (inputs) nixvim;
              inherit system;
            };

            mdx07-docker = pkgs.callPackage ./mdx07-docker.nix {
              inherit (packages)
                mdx07-riscv-gcc
                mdx07-init
                mdx07-tools
                mdx07-nvim
                ;
            };
          };

          devShells.default = pkgs.mkShell {
            packages =
              (with pkgs; [
                gnumake
                gdb
              ])
              ++ (with packages; [
                mdx07-riscv-gcc
                mdx07-init
                mdx07-tools
                mdx07-nvim
              ]);
          };
        };
    };
}
