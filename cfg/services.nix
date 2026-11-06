_: {
  services.geoclue2.enable = true;

  services.searx = {
    enable = false;
    settings = {
      server.port = 8585;
      server.bind_address = "127.0.0.1";
      server.secret_key = "extremely secret key";
      search = {
        safe_search = 1;
        default_lang = "en";
        formats = [
          "html"
          "json"
        ];
      };
      engines = [
        {
          name = "wikidata";
          engine = "wikidata";
          disabled = true;
        }
      ];
    };
  };

  services.suwayomi-server = {
    enable = true;
    settings.server.port = 7754;
  };

  # systemd sandboxing override for suwayomi-server (BOOT-5264 / systemd-analyze
  # security). Upstream module ships almost no confinement. Merged onto the
  # upstream unit via systemd.services.<name>.serviceConfig.
  #
  # Deliberately OMITTED to avoid breaking the JVM (Tachidesk) runtime:
  #   - MemoryDenyWriteExecute: JVM JIT needs W+X pages.
  #   - SystemCallFilter:       JVM trips restrictive seccomp sets.
  # Service is localhost:7754, writes only to its StateDirectory, and needs
  # outbound HTTP for extensions/manga -> AF_INET kept, all caps dropped.
  systemd.services.suwayomi-server.serviceConfig = {
    NoNewPrivileges = true;
    ProtectSystem = "strict"; # StateDirectory remains writable
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];
    LockPersonality = true;
    RemoveIPC = true;
    CapabilityBoundingSet = ""; # binds high port, needs no capabilities
    AmbientCapabilities = "";
  };

  services.automatic-timezoned.enable = true;
}
