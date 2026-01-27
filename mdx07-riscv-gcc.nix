{
  stdenv,
  riscv-gcc,
  autoPatchelfHook,
  zlib,
  expat,
  ncurses,
  lib,
}:
stdenv.mkDerivation {
  name = "mdx07-riscv-gcc";
  
  src = riscv-gcc;

  nativeBuildInputs = [ autoPatchelfHook ];
  
  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    expat
    ncurses
  ];
  
  sourceRoot = ".";
  
  installPhase = ''
    ls -la .
    ls -la $src
    mkdir -p $out
    cd source
    # Remove broken symlinks
    rm bin/clang bin/clang++ bin/riscv32-unknown-elf-clang++ bin/clang-cpp bin/riscv32-unknown-elf-clang bin/clang-cl
    # Move to output, skipping weird MacOS files, .DS_Store, etc.
    cp -r bin include lib libexec riscv32-unknown-elf share $out/
  '';
  
  dontCheckForBrokenSymlinks = true;
  
  meta = {
    description = "RISC-V GCC toolchain for MD307";
    homepage = "https://www.cse.chalmers.se/edu/resources/software/riscv32-gcc";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
