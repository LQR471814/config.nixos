config:
	sudo cp * /etc/nixos
	cd /etc/nixos && ( \
		(test -f ./DESKTOP && \
			sudo nixos-rebuild switch --flake ".#lqr471814-desktop") || \
		(sudo nixos-rebuild switch --flake ".#lqr471814-laptop") )

offline:
	sudo cp * /etc/nixos
	cd /etc/nixos && ( \
		(test -f ./DESKTOP && \
			sudo nixos-rebuild switch --flake ".#lqr471814-desktop" --offline) || \
		(sudo nixos-rebuild switch --flake ".#lqr471814-laptop" --offline) )

