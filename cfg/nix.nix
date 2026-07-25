_: {
  nixpkgs.config.allowUnfree = true;
  programs.nixos-cli.enable = true;
  programs.nix-ld.enable = true;

  # nix
  nix.settings = {
    substituters = [
      "https://cache.nixos-cuda.org"
      "https://watersucks.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "watersucks.cachix.org-1:6gadPC5R8iLWQ3EUtfu3GFrVY7X6I4Fwz/ihW25Jbv8="
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
}
