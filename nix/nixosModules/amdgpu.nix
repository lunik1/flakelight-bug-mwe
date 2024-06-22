# For systems with an AMD gpu

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.lunik1.system.amdgpu;
in
{
  options.lunik1.system.amdgpu = {
    enable = lib.mkEnableOption "AMD GPU drivers";
    support32Bit = lib.mkEnableOption "AMD GPU driver 32 bit support";
    opencl = lib.mkEnableOption "AMD GPU OpenCL support";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.kernelModules = [ "amdgpu" ];
      kernelModules = [ "kvm-amd" ];
    };
    services.xserver.videoDrivers = [ "amdgpu" ];

    nixpkgs.config.rocmSupport = true;

    hardware.opengl = {
      enable32Bit = true;
      extraPackages =
        with pkgs;
        [ amdvlk ]
        ++ lib.optionals cfg.opencl [
          rocm-opencl-icd
          rocm-opencl-runtime
        ];
      extraPackages32 = with pkgs; lib.mkIf cfg.support32Bit [ driversi686Linux.amdvlk ];
    };
  };
}
