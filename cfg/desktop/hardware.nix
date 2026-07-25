{ config, ... }:
{
  # fan module
  boot.kernelModules = [
    "kvm"
    "kvm_amd"
    "nct6775"
  ];

  # GPU
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  boot.extraModprobeConfig = ''
    options nvidia NVreg_TemporaryFilePath=/var/tmp
  '';
}
