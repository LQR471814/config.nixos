{ pkgs, ... }:
let
  inherit (pkgs)
    at-spi2-core
    dbus
    swaylock
    xdg-desktop-portal-gtk
    librsvg
    ;
in
{
  hardware.graphics.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WAYLAND_DISPLAY = "wayland-1";
    ZSH_SYSTEM_CLIPBOARD_USE_WL_CLIPBOARD = "";
    XDG_CURRENT_DESKTOP = "river";
  };

  services.dbus.packages = [
    at-spi2-core
  ];
  systemd.user.services.dbus-update-activation-environment = {
    enable = true;
    script = ''
      ${dbus}/bin/dbus-update-activation-environment --systemd --all
    '';
  };

  services.seatd.enable = true;
  services.upower.enable = true;

  programs.river-classic = {
    enable = true;
    xwayland.enable = true;
    extraPackages = [ swaylock ];
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true; # Specifically for River/wlroots
    extraPortals = [
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        # Use the GTK portal for everything by default
        default = [ "gtk" ];
      };
      # For screen sharing, prioritize the wlr portal
      river = {
        "org.freedesktop.impl.portal.ScreenShot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };

  programs.dconf.enable = true;
  programs.gdk-pixbuf.modulePackages = [ librsvg ];
  security.pam.services.swaylock = { };
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
}
