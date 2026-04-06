{
  inputs,
  lib,
  ...
} : let
hard = inputs.nixos-hardware;
in {
  imports = [
    "${hard}/common/cpu/amd"
    "${hard}/common/cpu/amd/pstate.nix"
    "${hard}/common/gpu/nvidia/prime.nix"
    "${hard}/common/gpu/nvidia/ada-lovelace"
    "${hard}/common/pc/laptop"
    "${hard}/common/pc/ssd"
  ];
  services.power-profiles-daemon.enable = lib.mkDefault true;
  services = {
    asusd.enable = lib.mkDefault true;
    supergfxd.enable = lib.mkDefault true;
  };
  boot.kernelParams = ["amdgpu.abmlevel=0"];
  hardware.nvidia = {
    powerManagement.enable = lib.mkDefault true;
    modesetting.enable = lib.mkDefault true;
    open = lib.mkDefault false;
    nvidiaSettings = lib.mkDefault true;
    prime = {
      amdgpuBusId = "PCI:66:00:0";
      nvidiaBusId = "PCI:65:00:0";
    };
  };
}
