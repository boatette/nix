{
    lib,
    pkgs,
    inputs,
    ...
}:

{
    imports = [
        ./hardware-configuration.nix
        inputs.noctalia-greeter.nixosModules.default
    ];

    boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages_latest;
        boot = {
            plymouth.enable = true;
            initrd = {
                kernelModules = [ "i915" ];
                verbose = false;
            };
            consoleLogLevel = 3;
            kernelParams = [
                "quiet"
                "udev.log_priority=3"
                "rd.systemd.show_status=auto"
            ];
            loader.timeout = 0;
        };
    };

    networking.hostName = "redux";
    networking.networkmanager.enable = true;

    time.timeZone = "Australia/Hobart";
    i18n.defaultLocale = "en_AU.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_AU.UTF-8";
        LC_IDENTIFICATION = "en_AU.UTF-8";
        LC_MEASUREMENT = "en_AU.UTF-8";
        LC_MONETARY = "en_AU.UTF-8";
        LC_NAME = "en_AU.UTF-8";
        LC_NUMERIC = "en_AU.UTF-8";
        LC_PAPER = "en_AU.UTF-8";
        LC_TELEPHONE = "en_AU.UTF-8";
        LC_TIME = "en_AU.UTF-8";
    };

    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    users.users."boatette" = {
        isNormalUser = true;
        description = "Jonathan Clark";
        extraGroups = [
            "networkmanager"
            "wheel"
        ];
        packages = [ ];
        shell = pkgs.fish;
    };

    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = with pkgs; [
        vim
        git
        wget
    ];

    nix.settings.experimental-features = [
        "nix-command"
        "flakes"
    ];

    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
        inter
    ];

    environment.shellAliases = lib.mkForce { };

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

    programs = {
        fish.enable = true;
        niri.enable = true;
        noctalia-greeter = {
            enable = true;

            settings = {
                appearance = {
                    hide_logo = true;
                };
                cursor = {
                    theme = "capitaine-cursors";
                    size = 24;
                    path = "${pkgs.capitaine-cursors}/share/icons";
                };
                keyboard = {
                    layout = "us";
                };
                output = {
                    scale = 1;
                    name = "eDP-1";
                };
            };
        };
    };

    system.stateVersion = "26.05";

}
