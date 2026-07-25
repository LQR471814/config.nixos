{ pkgs, ... }:
let
  inherit (pkgs)
    systemd
    ;
in
{
  # Fingerprint reader
  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    greetd.fprintAuth = true;
    swaylock = {
      fprintAuth = true;
      rules.auth = {
        fprintd = {
          order = 100;
          settings.control = "sufficient";
        };
        unix.order = 110;
      };
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="06cb", ATTRS{idProduct}=="00f9", ATTR{power/persist}="1", RUN="${pkgs.busybox}/bin/chmod 444 %S%p/../power/persist"
  '';

  # see: https://wiki.archlinux.org/title/Fprint#Sleeping_while_fprintd_is_still_running_breaks_fprintd
  systemd.services.kill-printd = {
    description = "Kill fprintd before sleep";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${systemd}/bin/systemctl stop fprintd";
    };
  };
}
