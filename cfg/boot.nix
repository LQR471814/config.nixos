_: {
  boot.loader = {
    # systemd-boot EFI boot loader
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  # temporarily disable ipv6
  # boot.kernel.sysctl = {
  #   "net.ipv6.conf.all.disable_ipv6" = 0;
  #   "net.ipv6.conf.default.disable_ipv6" = 0;
  # };
}
