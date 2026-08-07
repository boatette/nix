{
    flake.modules.homeManager.workstation =
        {
            pkgs,
            lib,
            config,
            ...
        }:
        let
            script =
                name: deps:
                pkgs.runCommand name { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
                    install -Dm755 ${./scripts/${name}} $out/bin/${name}
                    wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath deps}
                '';

            deps = with pkgs; [
                rsync
                util-linux
                coreutils
            ];

            scripts = {
                ssd-backup = script "ssd-backup" deps;
                ssd-restore = script "ssd-restore" deps;
            };
        in
        {
            home.packages = lib.attrValues scripts;

            systemd.user = {
                services = {
                    ssd-backup = {
                        Service = {
                            ExecStart = "${scripts.ssd-backup}/bin/ssd-backup";
                            IOSchedulingClass = "idle";
                            Nice = 10;
                            Type = "oneshot";
                        };
                        Unit.Description = "Mirror home data to the external SSD";
                    };

                    ssd-restore = {
                        Install.WantedBy = [ "default.target" ];
                        Service = {
                            ExecStart = "${scripts.ssd-restore}/bin/ssd-restore";
                            IOSchedulingClass = "idle";
                            Nice = 10;
                            Type = "oneshot";
                        };
                        Unit = {
                            ConditionPathExists = "!${config.home.homeDirectory}/.local/state/ssd-restore.stamp";
                            Description = "Restore home data from the external SSD on a fresh install";
                        };
                    };
                };

                timers.ssd-backup = {
                    Install.WantedBy = [ "timers.target" ];
                    Timer = {
                        OnCalendar = "daily";
                        Persistent = true;
                        RandomizedDelaySec = "30m";
                    };
                    Unit.Description = "Daily mirror of home data to the external SSD";
                };
            };
        };
}
