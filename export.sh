sudo cp * /etc/nixos

nmcli -t conn show | grep -q "^HJHOME:" && \
	sudo nmcli conn modify HJHOME ipv4.ignore-auto-dns yes ipv4.dns "192.168.1.10" && \
	sudo resolvectl domain "$(nmcli conn show HJHOME | grep "connection.interface-name:" | awk '{print $2}')" '~.'
