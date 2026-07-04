config:
	sudo cp * /etc/nixos
	cd /etc/nixos && ( \
		(test -f ./DESKTOP && \
			sudo nixos apply -y ".#lqr471814-desktop") || \
		(sudo nixos apply -y ".#lqr471814-laptop") \
	)

