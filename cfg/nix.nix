_: {
  nixpkgs.config.allowUnfree = true;
  programs.nixos-cli.enable = true;
  programs.nix-ld.enable = true;

  # nix
  nix.settings = {
    substituters = [
      "https://cache.nixos-cuda.org"
      "https://watersucks.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
    trusted-users = [ "lqr471814" ];
    download-buffer-size = "256M";
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };
  boot.loader.systemd-boot.configurationLimit = 8;

  # remote builder
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines = [
    {
      hostName = "192.168.1.121";
      sshUser = "nixbuild";
      sshKey = "/root/.ssh/mac_ed25519";

      system = "aarch64-linux";

      maxJobs = 8;
      speedFactor = 1;

      supportedFeatures = [
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
  ];
}
