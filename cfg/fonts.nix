{ pkgs, ... }:
let
  inherit (pkgs)
    nerd-fonts
    source-han-serif-vf-ttf
    source-han-serif
    ibm-plex
    ;
in
{
  fonts = {
    enableDefaultPackages = true;
    packages = [
      nerd-fonts.lilex
      source-han-serif-vf-ttf
      source-han-serif
      ibm-plex
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "IBM Plex Sans"
          "Source Han Serif SC VF"
        ];
        serif = [
          "IBM Plex Serif"
          "Source Han Serif SC VF"
        ];
        monospace = [
          "Lilex Nerd Font"
          "Source Han Serif SC VF"
        ];
      };
    };
  };
}
