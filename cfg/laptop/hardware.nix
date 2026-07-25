_: {
  # power management
  services.tlp = {
    enable = true;
    settings = {
      TLP_ENABLE = 1;
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      START_CHARGE_THRESH_BAT0 = 0;
      STOP_CHARGE_THRESH_BAT0 = 50;
    };
  };

  # virt
  boot.kernelModules = [
    "kvm"
    "kvm_intel"
  ];
}
