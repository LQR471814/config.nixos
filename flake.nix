{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    unstable.url = "nixpkgs/nixos-unstable";
  };
  outputs =
    inputs@{ nixpkgs, unstable, ... }:
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
        ];
      };
    };
}
