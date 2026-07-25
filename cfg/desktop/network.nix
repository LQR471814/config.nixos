{ pkgs }:
let
  inherit (pkgs) nushell;
in
{
  # networking (manual configuration)
  services.openssh.enable = true;

  networking = {
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
    ];

    interfaces.enp5s0 = {
      wakeOnLan.enable = true;
      ipv4.addresses = [
        {
          address = "192.168.1.13";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "192.168.1.254";
      interface = "enp5s0";
    };

    firewall = {
      enable = true;
      allowedUDPPorts = [ 9 ];
      allowedTCPPorts = [
        3478
        8080
        8188
      ];
    };
  };

  services.autosuspend = {
    enable = true;
    checks = {
      SSH = {
        class = "ActiveConnection";
        enabled = true;
        ports = 22;
      };
      Live = {
        class = "ExternalCommand";
        enabled = true;
        command = "${nushell}/bin/nu ${./live.nu}";
      };
    };
  };

  # services.nfs.server = {
  #   enable = true;
  #   exports = ''
  #     /backup 192.168.1.10(rw,fsid=0)
  #   '';
  # };
  # fileSystems."/backup" = {
  #   device = "/dev/disk/by-uuid/667d941b-4154-4150-985f-2e2c8484533a";
  #   fsType = "ext4";
  # };
  # systemd.tmpfiles.rules = [
  #   "d /backup 0777 root root -"
  # ];
}
