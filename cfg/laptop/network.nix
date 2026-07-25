{ pkgs, ... }: {
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNS = "";
        FallbackDNS = [ "192.168.1.10" ];
        DNSOverTLS = false;
        DNSSEC = false;
      };
    };
  };

  networking = {
    networkmanager.enable = true;
    networkmanager.dispatcherScripts = [
      {
        type = "basic";
        source = "${import ./wifi-hook.nix pkgs}/bin/wifi-hook";
      }
    ];
    firewall.allowedTCPPorts = [ 53317 ];
    firewall.allowedUDPPorts = [ 53317 ];
    nftables.enable = true;
    firewall.extraInputRules = ''
      ip saddr 192.168.122.0/24 tcp dport { 445, 139 } accept
      ip saddr 192.168.122.0/24 udp dport { 137, 138 } accept
    '';
  };
}
