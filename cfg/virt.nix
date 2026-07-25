{ pkgs, ... }:
let
  inherit (pkgs)
    qemu_kvm
    ;
in
{
  virtualisation = {
    docker.enable = false;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    libvirtd = {
      enable = true;
      qemu = {
        package = qemu_kvm;
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  # Delegate=yes must be set for `user.scope` because podman process runs
  # underneath it and must delegate cgroup for kind
  systemd.services."user.scope".serviceConfig.Delegate = true;

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  programs.virt-manager.enable = true;

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
}
