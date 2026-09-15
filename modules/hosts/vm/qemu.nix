{
  flake.modules.nixos.vm.virtualisation = {
    memorySize = 8192;
    cores = 4;
    diskSize = 20480;

    qemu = {
      enableSharedMemory = true;

      options = [
        "-vga none"
        "-device virtio-vga-gl,xres=1920,yres=1080"
        "-display gtk,gl=on,zoom-to-fit=on"
      ];
    };

    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };
}
