# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  system ? pkgs.system,
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

    # network
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
          "adbusers"
          "dialout"
          "podman"
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
      egl-wayland
      libsForQt5.qt5.qtwayland
      libdrm
      river-bedload
      xorg.xrdb
      at-spi2-core

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
      iotop
      arp-scan
      iftop

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
    ];

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        source-han-serif-vf-ttf
        source-han-serif
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

    services.dbus.packages = with pkgs; [
      at-spi2-core
    ];
    systemd.user.services.dbus-update-activation-environment = {
      enable = true;
      script = ''
        ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
      '';
    };

    services.seatd.enable = true;
    services.upower.enable = true;

    programs.river-classic = {
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

    # prevent verbose logs
    boot.kernelParams = [
      "quiet"
      "loglevel=3"
    ];
    services.greetd =
      let
        # Use `proptest` to find your display's connector ID
        # Prop ID can be found w/: `proptest | grep -B 5 'Broadcast RGB'`
        #
        # ${pkgs.libdrm}/bin/proptest -M i915 -D /dev/dri/card0 <CONNECTOR_ID> connector <PROP_ID> 1
        color-fix =
          if IS_DESKTOP then
            ""
          else
            ''
              /run/current-system/sw/bin/proptest -M i915 -D /dev/dri/card1 280 connector 266 1
              /run/current-system/sw/bin/proptest -M i915 -D /dev/dri/card1 271 connector 266 1
            '';
        river-launcher = pkgs.writeShellScriptBin "river-launcher" ''
          #!/bin/sh
          ${color-fix}
          unset WAYLAND_DISPLAY
          if [ -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
            source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
          fi
          ${pkgs.river-classic}/bin/river
        '';
      in
      {
        enable = true;
        settings.default_session = {
          user = "greeter";
          command = ''
            ${pkgs.tuigreet}/bin/tuigreet \
              --time \
              --remember \
              --asterisks \
              --user-menu \
              --cmd ${river-launcher}/bin/river-launcher
          '';
        };
      };

    xdg.portal = {
      enable = true;
      wlr.enable = true; # Specifically for River/wlroots
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          # Use the GTK portal for everything by default
          default = [ "gtk" ];
        };
        # For screen sharing, prioritize the wlr portal
        river = {
          "org.freedesktop.impl.portal.ScreenShot" = [ "wlr" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        };
      };
    };

    programs.dconf.enable = true;
    programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    security.pam.services.swaylock = { };
    security.pam.services.greetd.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;

    # searxng
    services.searx = {
      enable = true;
      settings = {
        server.port = 8585;
        server.bind_address = "127.0.0.1";
        server.secret_key = "extremely secret key";
        search = {
          safe_search = 1;
          default_lang = "en";
          formats = [
            "html"
            "json"
          ];
        };
        engines = [
          {
            name = "wikidata";
            engine = "wikidata";
            disabled = true;
          }
        ];
      };
    };

    # login
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };

    # shell
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_key_bindings fish_vi_key_bindings
      '';
    };
    programs.nix-ld.enable = true;

    # virtualisation
    virtualisation.docker.enable = false;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    virtualisation.spiceUSBRedirection.enable = true;
    networking.firewall.trustedInterfaces = [ "virbr0" ];
    programs.virt-manager.enable = true;
    programs.adb.enable = true;
    services.samba = {
      enable = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "nixos";
          "security" = "user";
          "map to guest" = "bad user";
        };
        shared = {
          path = "/srv/shared";
          browseable = true;
          "read only" = false;
          "guest ok" = true;
        };
      };
    };
    # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

    # local certificate
    security.pki.certificateFiles = [
      ./home_root.crt
    ];

    # nix
    nix.settings = {
      substituters = [
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
      trusted-users = [ "lqr471814" ];
      download-buffer-size = "256M";
    };
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    boot.loader.systemd-boot.configurationLimit = 8;

    # swap
    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 16 * 1024; # MB
      }
    ];

    # logging
    services.journald = {
      extraConfig = ''
        MaxRetentionSec=30day
        SystemMaxUse=1G
        SystemMaxFileSize=100M
      '';
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

        # nvidia gpu
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.graphics.enable = true;
        hardware.nvidia = {
          powerManagement.enable = true;
          modesetting.enable = true;
          open = true;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.beta;
        };

        # fan module
        boot.kernelModules = [
          "kvm"
          "kvm_amd"
          "nct6775"
        ];

        # networking (manual configuration)
        networking.firewall.enable = false;
        services.openssh.enable = true;

        networking.networkmanager = {
          enable = true;
          ensureProfiles.profiles = {
            "StaticWired" = {
              connection = {
                id = "StaticWired";
                type = "ethernet";
                interface-name = "enp4s0";
                autoconnect = true;
              };
              ipv4 = {
                method = "manual";
                address1 = "192.168.20.2/24";
              };
            };
          };
        };

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
      }
    else
      {
        # laptop
        networking.hostName = "lqr471814-laptop";

        # power management
        services.tlp = {
          enable = true;
          settings = {
            TLP_ENABLE = 1;
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            START_CHARGE_THRESH_BAT0 = 0;
            STOP_CHARGE_THRESH_BAT0 = 50;
          };
        };

        # virutalisation
        boot.kernelModules = [
          "kvm"
          "kvm_intel"
        ];

        # networking
        networking.networkmanager.dispatcherScripts = [
          {
            type = "basic";
            source = ./wifi-hook.sh;
          }
        ];
        networking.firewall.allowedTCPPorts = [ 53317 ];
        networking.firewall.allowedUDPPorts = [ 53317 ];
        networking.nftables.enable = true;
        networking.firewall.extraInputRules = ''
          ip saddr 192.168.122.0/24 tcp dport { 445, 139 } accept
          ip saddr 192.168.122.0/24 udp dport { 137, 138 } accept
        '';

        # Fingerprint reader
        # services.fprintd = {
        #   enable = true;
        #   tod.enable = true;
        #   tod.driver = pkgs.libfprint-2-tod1-goodix;
        # };
        # security.pam.services.login.fprintAuth = true;
        # security.pam.services.sudo.fprintAuth = true;
        # security.pam.services.greetd.fprintAuth = true;
        # security.pam.services.swaylock.fprintAuth = true;
        # security.pam.services.swaylock.rules.auth.fprintd.order = 100;
        # security.pam.services.swaylock.rules.auth.fprintd.settings.control = "sufficient";
        # security.pam.services.swaylock.rules.auth.unix.order = 110;
      }
  )
