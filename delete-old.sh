sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
sudo nix-collect-garbage --delete-older-than 30d
sudo nix-collect-garbage -d
sudo /run/current-system/bin/switch-to-configuration boot
