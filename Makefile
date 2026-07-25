config:
	sudo cp -r * /etc/nixos
	cd /etc/nixos && ( \
		(test -f ./DESKTOP && \
			sudo nixos apply -y ".#lqr471814-desktop") || \
		(sudo nixos apply -y ".#lqr471814-laptop") \
	)

lint:
	statix check

rm-old:
	sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
	sudo nix-collect-garbage --delete-older-than 64d
	sudo nix-collect-garbage -d
	sudo /run/current-system/bin/switch-to-configuration boot
