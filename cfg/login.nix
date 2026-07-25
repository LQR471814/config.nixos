{ pkgs, IS_DESKTOP, ... }:
let
  inherit (pkgs)
    tuigreet
    ;
in
{
  # prevent verbose logs
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
  ];
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };
  services.greetd =
    let
      # Use `proptest` to find your display's connector ID
      # Prop ID can be found w/: `proptest | grep -B 5 'Broadcast RGB'`
      #
      # ${pkgs.libdrm}/bin/proptest -M i915 -D /dev/dri/card0 <CONNECTOR_ID> connector <PROP_ID> 1
      fix-color =
        if IS_DESKTOP then
          ""
        else
          ''
            /run/current-system/sw/bin/proptest -M i915 -D /dev/dri/card1 280 connector 266 1
            /run/current-system/sw/bin/proptest -M i915 -D /dev/dri/card1 271 connector 266 1
          '';
      river-launcher = pkgs.writeShellScriptBin "river-launcher" ''
        #!/bin/bash

        ${fix-color}

        ${builtins.readFile ./launch-river.sh}
      '';
    in
    {
      enable = true;
      settings.default_session = {
        user = "greeter";
        command = ''
          ${tuigreet}/bin/tuigreet \
            --time \
            --remember \
            --asterisks \
            --user-menu \
            --cmd ${river-launcher}/bin/river-launcher
        '';
      };
    };
}
