{
  stdenv,
  unzip,
  autoPatchelfHook,
  wrapGAppsHook3,
  xorg,
  lib,
  mdx07-binaries,
}:
stdenv.mkDerivation {
  name = "mdx07-simserver";
  src = mdx07-binaries;

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    xorg.libXxf86vm
  ];

  installPhase =
    let
      arch =
        with stdenv.hostPlatform;
        if isLinux && isx86_64 then
          "linux-x64/simserver"
        else if isDarwin && isx86_64 then
          "macos-x64/Simserver.app"
        else if isDarwin && isAarch64 then
          "macos-arm64/Simserver.app"
        else
          throw "Could not find a binary for the specified platform";
    in
    ''
      mkdir -p $out/bin
      cp --dereference -r $src/${arch} $out/bin/
    '';

  meta = {
    description = "Simserver for MDx07";
    homepage = "https://git.chalmers.se/erik.sintorn/mdx07-binaries.git";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
