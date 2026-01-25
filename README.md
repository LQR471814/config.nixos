# Usage

```
# apply configuration
make

# to update deps
nix flake update

# to enroll fingerprint (if applicable)
sudo fprintd-enroll

# to add samba shared folder (if applicable)
sudo mkdir -p /srv/shared
sudo chown -R lqr471814:users /srv/shared
chmod 0755 /srv/shared
```

# Notes

If you have a GUI application you want to run with `sudo`, simply
add it to `overlays.nix` and call the `fixSudoGui` utility.

