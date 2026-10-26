{ inputs, lib, ... }:
let
  # flake.monitors transforms as wl_output.transform tags
  transforms = {
    "0" = "normal";
    "90" = ''@"90"'';
    "180" = ''@"180"'';
    "270" = ''@"270"'';
    "flipped" = "flipped";
    "flipped-90" = "flipped_90";
    "flipped-180" = "flipped_180";
    "flipped-270" = "flipped_270";
  };

  # xwayland misplaces clients at negative positions, so shift all monitors until none is negative
  monitorRules =
    monitors:
    let
      minX = lib.foldl' lib.min 0 (lib.mapAttrsToList (_: m: m.position.x) monitors);
      minY = lib.foldl' lib.min 0 (lib.mapAttrsToList (_: m: m.position.y) monitors);

      mode =
        m:
        let
          p = inputs.self.lib.parseMode m.mode;
        in
        lib.optionalString (m.mode != null)
          " .mode = .{ .width = ${p.width}, .height = ${p.height}, .refresh = ${lib.defaultTo "0" p.refresh} },";

      rule =
        name: m:
        "    .{ .name = \"${name}\",${mode m} .scale = ${toString (m.scale * 1.0)}, .transform = .${
              transforms.${toString m.transform}
            }, .x = ${toString (m.position.x - minX)}, .y = ${toString (m.position.y - minY)} },";
    in
    lib.concatStringsSep "\n" (lib.mapAttrsToList rule monitors);
in
{
  flake-file.inputs.aion = {
    # url = "github:boatette/aion";
    url = "git+file:///home/boatette/Projects/aion";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.aion =
    { config, pkgs, ... }:
    let
      inherit (config.constants) keyboard fonts flakeDir;

      monitors = inputs.self.monitors.${config.networking.hostName} or { };
    in
    {
      imports = [ inputs.aion.nixosModules.default ];

      programs.aion = {
        enable = true;
        package = inputs.aion.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          configFile = pkgs.replaceVars ./aion/config.zig {
            font = "${fonts.mono.name}:size=${toString fonts.mono.size}";
            xkbLayout = keyboard.layout;
            xkbOptions = keyboard.options;
            helpers = pkgs.local.aion-helpers;
            monitorRules = monitorRules monitors;
            rebuildBoot = (inputs.self.lib.rebuild flakeDir).os "boot";
          };
        };
      };

      xdg.terminal-exec = {
        enable = true;
        settings.default = [ "foot.desktop" ];
      };
    };

  flake.modules.homeManager.aion =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        local.aion-helpers
        wl-clipboard
        libnotify
        wlr-randr
        wlopm
      ];

      systemd.user = {
        services.aion-updates = {
          Unit.Description = "Check whether nixos-unstable is ahead of this system";
          Service = {
            ExecStart = "${pkgs.local.aion-helpers}/bin/aion-updates";
            Type = "oneshot";
          };
        };

        timers.aion-updates = {
          Install.WantedBy = [ "timers.target" ];
          Unit.Description = "Hourly nixpkgs update check";
          Timer = {
            OnStartupSec = "2m";
            OnUnitActiveSec = "1h";
          };
        };
      };

      # tty1 login starts aion; aion-session restarts the session's services and stops them on exit
      programs.zsh.profileExtra = ''
        if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
          exec aion-session
        fi
      '';
    };
}
