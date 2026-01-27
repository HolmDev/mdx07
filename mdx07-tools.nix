{
  stdenv,
  unzip,
  autoPatchelfHook,
  wrapGAppsHook3,
  libusb1,
  xorg,
  lib,
  mdx07-binaries,
}:
stdenv.mkDerivation {
  name = "mdx07-tools";
  src = mdx07-binaries;

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    libusb1
    xorg.libXxf86vm
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp --dereference -r $src/linux-x64/* $out/bin/
    # Make for some reason lacks the x flag
    chmod +x $out/bin/make
  '';

  meta = {
    description = "Tools for MDx07";
    homepage = "https://git.chalmers.se/erik.sintorn/mdx07-binaries.git";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
