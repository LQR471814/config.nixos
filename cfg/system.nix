{ pkgs, ... }: {
  # language
  i18n.defaultLocale = "en_US.UTF-8";

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # MB
    }
  ];

  services.journald = {
    extraConfig = ''
      MaxRetentionSec=30day
      SystemMaxUse=1G
      SystemMaxFileSize=100M
    '';
  };

  security.pki.certificateFiles = [
    ./root-ca.crt
  ];

  # see https://emudhra.we-have-a-problem.com/
  security.pki.caCertificateBlacklist = [
    # CVE-2026-111943
    "Comodo AAA Services root"
  ];

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };
}
