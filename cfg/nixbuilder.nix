_: {
  services.openssh = {
    enable = true;

    # SSH hardening (Lynis SSH-* NOT FOUND options).
    # Numbers sourced from CIS Benchmark + CVE-2024-6387 (regreSSHion)
    # mitigation guidance. Chosen to harden without breaking this host:
    #   - PasswordAuthentication off: nixbuild + user already use keys.
    #   - AllowTcpForwarding left at default (yes): tun2socks / libvirt rely on it.
    #   - No AllowGroups/AllowUsers: nixbuild is not in wheel; avoid lockout.
    #   - LoginGraceTime 30 (not 0): tolerate laptop sleep/wake.
    #   - ClientAliveCountMax 3 (not 0): avoid dropping idle interactive sessions.
    settings = {
      # Pre-auth SSH banner. /etc/issue.net is provided by cfg/hardening.nix.
      Banner = "/etc/issue.net";
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
      MaxAuthTries = 3; # CIS consensus
      MaxSessions = 4; # OpenSSH default 10; modest tightening
      LoginGraceTime = 30; # CVE-2024-6387 mitigation (0 = strictest)
      ClientAliveInterval = 300; # CIS Benchmark idle timeout
      ClientAliveCountMax = 3; # 300s * 3 before idle disconnect
      TCPKeepAlive = false;
      LogLevel = "VERBOSE"; # logs key fingerprint on login
    };
  };

  users.groups.nixbuild = { };

  users.users.nixbuild = {
    isSystemUser = true;
    group = "nixbuild";
    useDefaultShell = true;

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../nix-builder.pub)
    ];
  };

  nix.settings = {
    trusted-users = [
      "root"
      "nixbuild"
    ];
    max-jobs = "auto";
    cores = 0;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
