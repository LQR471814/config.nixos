pkgs:
with pkgs;
let
  nmcli = "${networkmanager}/bin/nmcli";
  wg-quick = "${wireguard-tools}/bin/wg-quick";
  script = writeTextFile {
    name = "wifi-hook.nu";
    text = ''
      #!${nushell}/bin/nu

      def main [args: string] {
        let args = $args | from json
        let intf = $args.0
        let action = $args.1
        let conn = ${nmcli} -t -f ACTIVE,SSID dev wifi list --rescan no
          | lines
          | split column ":"
          | rename active ssid
          | where active == yes
          | get 0?.ssid

        const CONFIG = "/home/lqr471814/Applications/Wireguard/wireguard.conf"

        def "vpn up" [] {
          ${wg-quick} up $CONFIG
        }

        def "vpn down" [] {
          ${wg-quick} down $CONFIG
        }

        print $action $conn

        match $action {
          "connectivity-change" => {
            match $conn {
              "HJHOME" => { vpn down }
              "" => { vpn down }
              _ => {
                vpn down | complete
                vpn up
              }
            }
          }
          "down" => {
            vpn down
          }
        }
      }
    '';
  };
in
writeShellApplication {
  name = "wifi-hook";
  runtimeInputs = [ nushell ];
  text = ''
    exec nu ${script} "[\"$1\",\"$2\"]"
  '';
}
