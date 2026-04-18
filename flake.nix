{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:flox/nixpkgs/unstable";
  };
  outputs =
    inputs@{ nixpkgs, ... }:
    let
      IS_DESKTOP = builtins.pathExists ./DESKTOP;
      hostname = if IS_DESKTOP then "lqr471814-desktop" else "lqr471814-laptop";
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs system;
        };
        modules = [
          (import ./configuration.nix)
        ];
      };
    };
}
