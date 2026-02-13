{
  stdenv,
  mdx07-templates-library,
  writeText,
  lib,
}:
stdenv.mkDerivation {
  name = "mdx07-templates";

  src = mdx07-templates-library;

  patchPhase = ''
    cp ${writeText ".asm-lsp.toml" ''
      [default_config]
      version = "0.10.1"
      assembler = "gas"
      instruction_set = "riscv"

      [opts]
      compiler = "riscv32-none-elf-gcc"
      diagnostics = true
      default_diagnostics = true
    ''} "templates/Basic templates/md307-master/.asm-lsp.toml"

    cp ${writeText "compile-flags.txt" ''
      -Wall -Wextra -std=c99 -MMD -march=rv32imf_zicsr -mabi=ilp32f
    ''} "templates/Basic templates/md307-master/compile_flags.txt"

    find ./ -path "*.vscode*" -delete

    substituteInPlace "templates/Basic templates/md307-master/Makefile" \
      --replace-fail "riscv32-unknown-elf" "riscv32-none-elf"
  '';

  installPhase = ''
    mkdir -p $out
    cp -r --no-preserve=all templates/* $out
  '';

  meta = {
    description = "Project templates for MDx07";
    homepage = "https://git.chalmers.se/haelias/mdx07-templates-library.git";
    license = lib.licenses.unfree;
    platforms = lib.platforms.all;
  };
}
