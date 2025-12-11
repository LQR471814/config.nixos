# Usage

```
# apply configuration
make

# to update deps
nix flake update

# to enroll fingerprint (if applicable)
sudo fprintd-enroll
```

# Notes

If you have a GUI application you want to run with `sudo`, simply
add it to `overlays.nix` and call the `fixSudoGui` utility.

