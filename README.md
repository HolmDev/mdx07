# NVIM Debugging Suite for MD307

This is a Nix environment for the course Machine oriented programming (EDA482). Normally, the course provides a VSCode plugin which downloads and manages the toolchain for developing and debugging. However, this does not suit everyone, as it forces VSCode onto the users, and does not play nice with NixOS. This project was created to address these problems by allowing development using Neovim on Nix.

# Usage

Run `nix develop github:HolmDev/mdx07`. You may have to set `NIXPKGS_ALLOW_UNFREE=1`, as various of the buildtools are unlicensed or propriatary.

To initialize a project from a template, use the `mdx07-init` script in an empty folder.

To edit files, use `nvim`, which comes preconfigured for C/Assembly programming, with [nvim-dap](https://github.com/mfussenegger/nvim-dap) and [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui).

To start the simserver, simply execute `:MDx07StartSimserver` in Neovim or `simserver` in the shell. You can stop it with `:MDx07StopSimserver`

To build a project, just use `make` or the Neovim alias `:MDx07Build`.

To get a fancy debugger view, run `:MDx07ToggleUI`. Then use the buttons and the `:Dap*` commands to control the debugger. To interface with the GDB instance running, use the split labeled `dap-repl`. This is neccessary to inspect the memory.

# Usage: Docker image

Because they are people that have yet to be enlightened by Nix's glory, one output (`mdx07-docker`) is a Docker image tarball, which can be used on systems that do not use Nix, although the image must be built on a Nix machine/container.

The image is built with [`dockerTools.streamLayeredImage`](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools) as follows:

```sh
# (On a Nix machine/container) Export to tarball
NIXPKGS_ALLOW_UNFREE=1 nix build --impure .#mdx07-docker
./result > mdx07.tar

# (On the target machine) Load into podman/Docker
podman load -i mdx07.tar
```

As we need to forward X11 programs to the host, we need to make sure that X11
can communicate through the docker. The prerequisites are:
1. `$DISPLAY` is defined as the active X11 display.
2. `xhost` returns a line like `SI:localuser:<user>`. If not, add yourself by running `xhost +SI:localuser:$USER`.

To launch an ephemeral container run: 
```sh
# Don't forget to include your desired path
podman run --rm -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v "$HOME/.Xauthority:/root/.Xauthority:rw" mdx07:latest
```

Then simply follow the general instructions, except the `nix develop` command.

# Disclaimers
## This is not for MD407

Since the course currently uses the MD307 devboard with a RISCV32I processor,
no effort has been put towards making it compatible against the older MD407 and
its ARM processor. However, this project may be well suited as a start if you
wish to implement that.

## This has not been tested against the MD307 hardware (yet)

Due to a lack of access to the physical MD307 hardware, this project has not
yet been tested against this. This is in the works. This is probably just a
matter of making `openocd` from `mdx07-tools` interface with `/dev/ttyUSB0`.

# Credits
- [yaanae](https://github.com/yaanae) for creating the inital environment by reversing the VSCode plugin
- [erik.sintorn](https://git.chalmers.se/erik.sintorn) for the binaries for `openocd`, `simserver`
- [haelias](https://git.chalmers.se/haelias) for the templates
- and many more...
