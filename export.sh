sudo cp * /etc/nixos
nmcli -t conn show | grep -q "^HJHOME:" && \
	sudo nmcli conn modify HJHOME ipv4.ignore-auto-dns yes ipv4.dns "192.168.1.10"
