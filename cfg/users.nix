{
  unstablePkgs,
  ...
}:
{
  users.users = {
    tun2socks = {
      isNormalUser = true;
    };
    lqr471814 = {
      isNormalUser = true;
      extraGroups = [
        "seat"
        "wheel"
        "video"
        "sandbar"
        "wireshark"
        "libvirtd"
        "kvm"
        "adbusers"
        "dialout"
        "podman"
      ]; # enable sudo for user
      shell = unstablePkgs.nushell;
    };
  };
}
