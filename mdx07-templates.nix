{
  stdenv,
  mdx07-templates,
  writeText,
  lib,
}:
stdenv.mkDerivation {
  name = "mdx07-templates";

  src = mdx07-templates;

  unpackPhase = ''
    mkdir -p $out
    cp -r --no-preserve=all $src/templates/* $out

    cp ${writeText ".asm-lsp.toml" ''
      [default_config]
      version = "0.10.1"
      assembler = "gas"
      instruction_set = "riscv"

      [opts]
      compiler = "riscv32-unknown-elf-gcc"
      diagnostics = true
      default_diagnostics = true
    ''} "$out/Basic templates/md307-master/.asm-lsp.toml"

    cp ${writeText "compile-flags.txt" ''
      -g -Wall -Wextra -std=c99 -MMD -march=rv32imf_zicsr -mabi=ilp32f
    ''} "$out/Basic templates/md307-master/compile_flags.txt"
  '';

  meta = {
    description = "Project templates for MDx07";
    homepage = "https://git.chalmers.se/haelias/mdx07-templates-library.git";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
