{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (import ./overlays.nix)
  ];

  environment.systemPackages = with pkgs; [
    # wm
    sandbar
    wlr-randr
    wl-clipboard
    tofi
    upower
    brightnessctl
    papirus-icon-theme
    grim
    slurp
    lswt
    egl-wayland
    libsForQt5.qt5.qtwayland
    libdrm
    river-bedload
    xrdb
    at-spi2-core
    accerciser

    # basic utils
    curl
    home-manager
    bc
    gnumake
    git
    busybox
    wireguard-tools
    lm_sensors
    s-tui
    linuxKernel.packages.linux_zen.cpupower
    arduino-ide
    screen
    xhost
    lxqt.lxqt-sudo
    wayland-utils
    iotop
    arp-scan
    iftop
    gparted
    usbutils
    hwdata
    ethtool
    wakeonlan

    # core gui apps
    alacritty
    wireshark
    tcpdump

    # virtualisation
    qemu
    virt-manager
    virt-viewer
    virtio-win
    iw
    docker-compose
    android-tools
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
