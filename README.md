# Usage

```sh
# apply configuration
make

# to update deps
nix flake update

# to delete previous fingerprint & enroll (if applicable)
#
# NOTE: enrolling fingerprint for root is usually not what you
# want to do!
sudo fprintd-delete "$USER"
sudo fprintd-enroll "$USER"

# verify fingerprint
sudo fprintd-verify "$USER"

# to add samba shared folder (if applicable)
sudo mkdir -p /srv/shared
sudo chown -R lqr471814:users /srv/shared
chmod 0755 /srv/shared
```

# Notes

If you have a GUI application you want to run with `sudo`, simply
add it to `overlays.nix` and call the `fixSudoGui` utility.

