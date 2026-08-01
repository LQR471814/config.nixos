{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    unstable.url = "nixpkgs/nixos-unstable";
    nixos-cli = {
      url = "github:nix-community/nixos-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      unstable,
      nixos-cli,
      ...
    }:
    let
      IS_DESKTOP = builtins.pathExists ./DESKTOP;

      hostname = if IS_DESKTOP then "lqr471814-desktop" else "lqr471814-laptop";
      system = "x86_64-linux";
      unstablePkgs = unstable.legacyPackages.${system};

      modules = [
        (_: {
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
        })

        ./cfg/system.nix
        ./cfg/users.nix
        ./cfg/hardware.nix
        ./cfg/audio.nix
        ./cfg/bluetooth.nix
        ./cfg/boot.nix
        ./cfg/desktop.nix
        ./cfg/disks.nix
        ./cfg/fonts.nix
        ./cfg/input.nix
        ./cfg/login.nix
        ./cfg/nix.nix
        ./cfg/packages.nix
        ./cfg/printing.nix
        ./cfg/services.nix
        ./cfg/virt.nix
        ./cfg/wireshark.nix

        nixos-cli.nixosModules.nixos-cli
      ]
      ++ (
        if IS_DESKTOP then
          [
            ./cfg/desktop/system.nix.nix
            ./cfg/desktop/hardware.nix
            ./cfg/desktop/network.nix
            ./cfg/desktop/live.nix
          ]
        else
          [
            ./cfg/laptop/system.nix
            ./cfg/laptop/hardware.nix
            ./cfg/laptop/network.nix
            # ./cfg/laptop/fingerprint.nix
          ]
      );
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs = {
          inherit
            inputs
            system
            unstablePkgs
            IS_DESKTOP
            ;
        };
      };
    };
}
