_: {
  services.openssh.enable = true;

  users.groups.nixbuild = { };

  users.users.nixbuild = {
    isSystemUser = true;
    group = "nixbuild";
    useDefaultShell = true;

    openssh.authorizedKeys.keyFiles = [
      ../nix-builder.pub
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
