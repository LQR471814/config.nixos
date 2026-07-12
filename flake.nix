{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
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
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs system unstablePkgs;
        };
        modules = [
          (import ./configuration.nix)
          nixos-cli.nixosModules.nixos-cli
        ];
      };
      # test = import ./wifi-hook.nix unstablePkgs;
    };
}
