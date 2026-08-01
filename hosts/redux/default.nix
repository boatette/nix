{
    imports = [
        ./hardware-configuration.nix
        ../../modules/nixos
    ];

    networking.hostName = "redux";

    boot.initrd.kernelModules = [ "i915" ];

    programs.noctalia-greeter.settings.output = {
        name = "eDP-1";
        scale = 1;
    };

    fileSystems."/mnt/storage" = {
        device = "/dev/disk/by-uuid/40124632-4404-4350-8054-440bbdbefd99";
        fsType = "ext4";
        options = [
            "nofail"
            "noatime"
            "x-systemd.automount"
            "x-systemd.device-timeout=5s"
            "x-systemd.mount-timeout=5s"
            "x-gvfs-show"
        ];
    };

    system.stateVersion = "26.05";
}
