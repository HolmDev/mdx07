{
  dockerTools,
  busybox,
  mdx07-riscv-gcc,
  mdx07-init,
  mdx07-tools,
  mdx07-nvim,
}:
dockerTools.streamLayeredImage {
  name = "mdx07";
  tag = "latest";
  contents = [
    dockerTools.caCertificates
    busybox
    mdx07-nvim
    mdx07-init
    mdx07-tools
    mdx07-riscv-gcc
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
