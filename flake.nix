{
  description = "NVIM debugging suite for MDx07";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    mdx07-templates-library = {
      url = "git+https://git.chalmers.se/haelias/mdx07-templates-library.git";
      flake = false;
    };

    mdx07-binaries = {
      url = "git+https://git.chalmers.se/erik.sintorn/mdx07-binaries.git";
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
    { flake-parts, nixpkgs, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      perSystem =
        { pkgs, system, ... }:
        rec {
          packages = {
            mdx07-simserver = pkgs.callPackage ./mdx07-simserver.nix { inherit (inputs) mdx07-binaries; };

            md307-openocd-cfg = pkgs.callPackage ./md307-openocd-cfg.nix { inherit (inputs) mdx07-binaries; };

            mdx07-init = pkgs.callPackage ./mdx07-init.nix { inherit (packages) mdx07-templates; };

            mdx07-templates = pkgs.callPackage ./mdx07-templates.nix {
              inherit (inputs) mdx07-templates-library;
            };

            riscv32-embedded-gcc =
              let
                riscv32-embedded = import nixpkgs {
                  inherit system;
                  crossSystem = {
                    config = "riscv32-none-elf";
                    libc = "newlib-nano";
                    gcc = {
                      arch = "rv32imf_zicsr";
                      abi = "ilp32f";
                    };
                  };
                };
              in
              riscv32-embedded.buildPackages.gcc;

            mdx07-nvim = pkgs.callPackage ./mdx07-nvim.nix {
              inherit (inputs) nixvim;
              inherit (packages) mdx07-simserver;
              inherit system;
            };

            md307-docker = pkgs.callPackage ./md307-docker.nix {
              inherit (packages)
                md307-openocd-cfg
                mdx07-init
                mdx07-nvim
                mdx07-simserver
                riscv32-embedded-gcc
                ;
            };
          };

          devShells.default = pkgs.mkShell {
            packages =
              (with pkgs; [
                gdb
                gnumake
                openocd
              ])
              ++ (with packages; [
                md307-openocd-cfg
                mdx07-init
                mdx07-nvim
                mdx07-simserver
                riscv32-embedded-gcc
              ]);
          };
        };
    };
}
