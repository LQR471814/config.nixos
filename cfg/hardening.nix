_: {
  # Kernel sysctl hardening.
  #
  # Values sourced from Lynis default profile (KRNL-6000), i.e.
  #   <lynis>/share/lynis/default.prf  (config-data=sysctl;<key>;<expected>;...)
  # which in turn cites kernel.org/doc/Documentation/sysctl/.
  #
  # Deliberately OMITTED (would break this host's workflow):
  #   - kernel.modules_disabled = 1   -> blocks loading kvm/usb modules
  #   - net.ipv4.conf.all.forwarding = 0 / rp_filter = 1
  #                                   -> breaks libvirt/podman (virbr0) NAT
  boot.kernel.sysctl = {
    "dev.tty.ldisc_autoload" = 0; # disable autoload of TTY line disciplines
    "fs.protected_fifos" = 2; # restrict FIFO creation in world-writable dirs
    "fs.protected_regular" = 2; # restrict regular file creation likewise
    "fs.suid_dumpable" = 0; # no core dumps for setuid binaries
    "kernel.kptr_restrict" = 2; # hide kernel pointers from all users
    "kernel.sysrq" = 0; # disable magic SysRq key
    "kernel.unprivileged_bpf_disabled" = 1; # restrict BPF to privileged users
    "net.core.bpf_jit_harden" = 2; # harden BPF JIT against spraying

    # Log packets with no reverse path (martians). Informational, non-breaking.
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;

    # Ignore ICMP redirects (default scope only; "all" left at kernel default
    # to avoid interfering with virt bridges).
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
  };

  # Disable uncommon network protocols flagged by Lynis NETW-3200.
  # None used on this host; blacklisting prevents accidental module load.
  boot.blacklistedKernelModules = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
  ];

  # FILE-6310 partial: wipe /tmp on boot. Using cleanOnBoot rather than a
  # tmpfs mount so large nix builds are not constrained by RAM on this
  # nixbuild host.
  boot.tmp.cleanOnBoot = true;

  # BANN-7126: legal login banner. /etc/issue is shown at the console login
  # prompt; issue.net is the pre-auth banner for network (SSH) logins.
  environment.etc."issue".text = ''
    Authorized access only. All activity may be monitored and reported.
  '';
  environment.etc."issue.net".text = ''
    Authorized access only. All activity may be monitored and reported.
  '';
}
