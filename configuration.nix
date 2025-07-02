# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # drivers and hardware
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking
  networking.hostName = "lqr471814-laptop"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # time zone.
  time.timeZone = "Asia/Shanghai";

  # language
  i18n.defaultLocale = "en_US.UTF-8";

  # printing
  services.printing.enable = true;

  # audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;

  # inputs
  services.libinput.enable = true;

  # user accounts
  users.users = {
    tun2socks = {
      isNormalUser = true;
    };
    lqr471814 = {
      isNormalUser = true;
      extraGroups = [ "seat" "wheel" "video" "sandbar" ]; # enable sudo for user
      shell = pkgs.zsh;
    };
  };

  # programs and packages

  # packages installed in system profile
  nixpkgs.overlays = [
    (import ./overlays.nix)
  ];

  environment.systemPackages = with pkgs; [
    # wm
    river
    sandbar
    wlr-randr
    wl-clipboard
    tofi
    upower
    light

    # basic utils
    neovim
    curl
    home-manager
    bc
    gnumake
    git

    # core gui apps
    alacritty
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      source-han-serif-vf-ttf
      ibm-plex
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "IBM Plex Sans" ];
        serif = [ "IBM Plex Serif" ];
        monospace = [ "JetBrainsMono NF" ];
      };
    };
  };

  # wayland
  hardware.graphics.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WAYLAND_DISPLAY = "wayland-1";
  };

  services.seatd.enable = true;
  services.upower.enable = true;

  systemd.services.clear-river-flag = {
    description = "clears /tmp/RIVER_ON";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/current-system/sw/bin/rm -f /tmp/RIVER_ON";
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "greeter";
	command = ''
	  ${pkgs.greetd.tuigreet}/bin/tuigreet \
	    --time \
	    --asterisks \
	    --user-menu \
	    --cmd "env -u WAYLAND_DISPLAY river"
	'';
      };
    };
  };

  # shell
  programs.zsh = import ./zsh.nix { inherit pkgs; };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

