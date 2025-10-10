# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

let
  IS_DESKTOP = builtins.pathExists ./DESKTOP;
in
lib.attrsets.recursiveUpdate
  {
    # drivers and hardware
    imports = [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nixpkgs.config.allowUnfree = true;

    # use latest kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # systemd-boot EFI boot loader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # power
    services.tlp.enable = true;

    # networking
    networking.networkmanager.enable = true;
    services.resolved = {
      enable = true;
      dnssec = "false";
      dnsovertls = "false";
      extraConfig = ''
        [Resolve]
        DNS=
        FallbackDNS=192.168.1.10
      '';
    };

    # temporarily disable ipv6
    # boot.kernel.sysctl = {
    #   "net.ipv6.conf.all.disable_ipv6" = 0;
    #   "net.ipv6.conf.default.disable_ipv6" = 0;
    # };

    # time zone.
    time.timeZone = "America/Los_Angeles";

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
    users.groups.wireshark = { };
    users.users = {
      tun2socks = {
        isNormalUser = true;
      };
      lqr471814 = {
        isNormalUser = true;
        extraGroups = [
          "seat"
          "wheel"
          "video"
          "sandbar"
          "wireshark"
          "libvirtd"
          "kvm"
        ]; # enable sudo for user
        shell = pkgs.fish;
      };
    };

    # programs and packages

    # packages installed in system profile
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
      light
      papirus-icon-theme
      grim
      slurp
      lswt

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
      linuxKernel.packages.linux_lqx.cpupower
      arduino-ide
      screen
      xorg.xhost
      lxqt.lxqt-sudo
      wayland-utils

      # core gui apps
      alacritty
      wireshark

      # virtualisation
      qemu
      virt-manager
      virtio-win
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
          sansSerif = [
            "IBM Plex Sans"
            "Source Han Serif SC VF"
          ];
          serif = [
            "IBM Plex Serif"
            "Source Han Serif SC VF"
          ];
          monospace = [
            "IBM Plex Mono"
            "JetBrainsMono NF"
            "Source Han Serif SC VF"
          ];
        };
      };
    };

    # desktop environment
    hardware.graphics.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WAYLAND_DISPLAY = "wayland-1";
      ZSH_SYSTEM_CLIPBOARD_USE_WL_CLIPBOARD = "";
      XDG_CURRENT_DESKTOP = "river";
    };

    systemd.user.services.dbus-update-activation-environment = {
      enable = true;
      script = ''
        ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      '';
    };

    services.seatd.enable = true;
    services.upower.enable = true;

    programs.river = {
      enable = true;
      xwayland.enable = true;
      extraPackages = with pkgs; [ swaylock ];
    };

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

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      config.common.default = [ "wlr" ];
    };

    programs.dconf.enable = true;
    programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    security.pam.services.swaylock = { };
    security.pam.services.greetd.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;

    # shell
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_key_bindings fish_vi_key_bindings
      '';
    };
    programs.nix-ld.enable = true;

    # docker
    virtualisation.docker.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        swtpm.enable = true;
      };
    };
    programs.virt-manager.enable = true;

    # editor
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

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
    networking.firewall.allowedTCPPorts = [ 53317 ];
    networking.firewall.allowedUDPPorts = [ 53317 ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # local certificate
    security.pki.certificateFiles = [
      ./home_root.crt
    ];

    nix.settings = {
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

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
  (
    if IS_DESKTOP then
      {
        # desktop
        networking.hostName = "lqr471814-desktop";

        # NFS
        services.nfs.server = {
          enable = true;
          exports = ''
            /backup 192.168.1.10(rw,fsid=0)
          '';
        };
        fileSystems."/backup" = {
          device = "/dev/disk/by-uuid/667d941b-4154-4150-985f-2e2c8484533a";
          fsType = "ext4";
        };
        systemd.tmpfiles.rules = [
          "d /backup 0777 root root -"
        ];

        # swap
        swapDevices = [
          {
            device = "/var/lib/swapfile";
            size = 16 * 1024; # MB
          }
        ];

        # networking
        networking.interfaces.enp4s0.useDHCP = false;
        networking.interfaces.enp4s0.ipv4.addresses = [
          {
            address = "192.168.1.11";
            prefixLength = 24;
          }
        ];
        networking.defaultGateway = {
          address = "192.168.1.254";
          interface = "enp4s0";
        };
        networking.firewall.allowedTCPPorts = [
          2049
          53317
        ];
        networking.firewall.allowedUDPPorts = [
          2049
          53317
        ];

        # nvidia gpu
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.graphics.enable = true;
        hardware.nvidia = {
          modesetting.enable = true;
          open = true;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        # fan module
        boot.kernelModules = [
          "kvm"
          "kvm_amd"
          "nct6775"
        ];

        services.openssh.enable = true;
      }
    else
      {
        # laptop
        networking.hostName = "lqr471814-laptop";

        # power
        services.tlp.settings = {
          TLP_ENABLE = 1;
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          START_CHARGE_THRESH_BAT0 = 40;
          STOP_CHARGE_THRESH_BAT0 = 80;
        };

        boot.kernelModules = [
          "kvm"
          "kvm_intel"
        ];

        networking.networkmanager.dispatcherScripts = [
          {
            type = "basic";
            source = ./wifi-hook.sh;
          }
        ];
      }
  )
