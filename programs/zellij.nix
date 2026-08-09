{
    flake.homeModules.dev =
        { pkgs, ... }:
        {
            home.packages = [
                pkgs.zellij

                (pkgs.writeShellApplication {
                    name = "zellij-clear-all-sessions";
                    meta.description = "kill and delete every zellij session";
                    runtimeInputs = [ pkgs.zellij ];
                    text = ''
                        zellij kill-all-sessions
                        zellij delete-all-sessions
                    '';
                })
            ];
        };
}
