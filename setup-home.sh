# clone river config
# WIP

# restart WM
# Ctrl+Shift+Super+Q

# pull wireguard config
# WIP

# connct to wireguard if not on local network
wg-up

# pull syncthing secrets
syncthing-cfg-pull

# enable unfree packages & experimental nix features
mkdir -p ~/.config/nixpkgs && echo "{ allowUnfree = true; }" > ~/.config/nixpkgs/config.nix
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# setup home-manager
git clone https://github.com/LQR471814/config.home-manager ~/.config/home-manager
cd ~/.config/home-manager
make

# setup nvim config
git clone https://github.com/LQR471814/config.nivm ~/.config/nvim

# install nvim deps
nvim

# setup GPG key pair
gpg --gen-key
pass init <USER ID provided>
