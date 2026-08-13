_: {
  # time zone.
  time.timeZone = "America/Los_Angeles";

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
}
