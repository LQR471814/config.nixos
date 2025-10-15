#!/run/current-system/sw/bin/sh

IFACE="$1"
ACTION="$2"
CONN=$(/run/current-system/sw/bin/nmcli -t -f ACTIVE,SSID dev wifi | /run/current-system/sw/bin/awk -F: '$1=="yes"{print $2; exit}')

CONF="/home/lqr471814/files/Wireguard/wireguard.conf"

up() {
	/run/current-system/sw/bin/wg-quick up "$CONF"
}
down() {
	/run/current-system/sw/bin/wg-quick down "$CONF"
}

echo $ACTION $CONN

case "$ACTION" in
	connectivity-change)
		case "$CONN" in
			HJHOME) down ;;
			*) down; up ;;
		esac
		;;
	down) down ;;
esac

