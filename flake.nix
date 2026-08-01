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
        ./configuration.nix
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
        ./cfg/system.nix
        ./cfg/users.nix
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
          inherit inputs system unstablePkgs IS_DESKTOP;
        };
      };
    };
}
