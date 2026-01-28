{
  stdenv,
  lib,
  mdx07-binaries,
}:
stdenv.mkDerivation {
  name = "mdx07-openocd.cfg";
  src = mdx07-binaries;

  installPhase = ''
    mkdir -p $out/share/openocd/scripts/boards
    cp --dereference $src/linux-x64/openocd.cfg $out/share/openocd/scripts/boards/md307.cfg
  '';

  meta = {
    description = "OpenOCD config for MD307";
    homepage = "https://git.chalmers.se/erik.sintorn/mdx07-binaries.git";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
