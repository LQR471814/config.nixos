{ pkgs, ... }:
{
  services.udev = {
    enable = true;
    packages =
      let
        inherit (pkgs) saleae-logic-2;
      in
      [
        saleae-logic-2
      ];
  };
}
