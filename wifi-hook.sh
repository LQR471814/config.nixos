#!/run/current-system/sw/bin/bash

IFACE="$1"
ACTION="$2"
CONN=$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="yes"{print $2; exit}')

echo "$CONN" > /home/lqr471814/conn_id
echo "$ACTION" > /home/lqr471814/act

wg-down
if ([ "$ACTION" = "up" ] || [ "$ACTION" = "connectivity-change" ]) && [ "$CONN" != "HJHOME" ]; then
	wg-up

	echo "UP" > /home/lqr471814/vpn_status
	exit 0
fi

echo "DOWN" > /home/lqr471814/vpn_status

