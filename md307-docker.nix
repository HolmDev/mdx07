{
  busybox,
  dockerTools,
  gdb,
  gnumake,
  md307-openocd-cfg,
  mdx07-init,
  mdx07-nvim,
  mdx07-simserver,
  openocd,
  riscv32-embedded-gcc,
}:
dockerTools.streamLayeredImage {
  name = "md307";
  tag = "latest";
  contents = [
    dockerTools.caCertificates
    busybox
    md307-openocd-cfg
    mdx07-init
    mdx07-nvim
    mdx07-simserver
    openocd
    gnumake
    gdb
    riscv32-embedded-gcc
  ];

  enableFakechroot = true;
  fakeRootCommands = ''
    touch /etc/{passwd,group}
    ${busybox}/bin/addgroup -g 0 root
    ${busybox}/bin/adduser -s ${busybox}/bin/ash -H -D -G root -u 0 root
  '';

  config = {
    Cmd = [
      "ash"
    ];
  };
}
