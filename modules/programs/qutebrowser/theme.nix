{ inputs, ... }:
{
  flake-file.inputs.noctalia-community-templates = {
    url = "github:noctalia-dev/community-templates";
    flake = false;
  };

  flake.modules.homeManager.qutebrowser.xdg.configFile."qutebrowser/noctalia/.keep".text = "";

  flake.modules.homeManager.noctalia =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      reload = pkgs.writeShellApplication {
        name = "noctalia-qutebrowser-reload";
        runtimeInputs = with pkgs; [
          coreutils
          socat
        ];
        text = ''
          hash="$(id -un | tr -d '\n' | md5sum | cut -d' ' -f1)"
          socket="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/qutebrowser/ipc-$hash"
          [ -S "$socket" ] || exit 0

          printf '%s\n' '{"args": [":config-source"], "target_arg": null, "protocol_version": 1}' \
            | socat -lf /dev/null - UNIX-CONNECT:"$socket"
        '';
      };
    in
    {
      programs.noctalia.settings.theme.templates.user.qutebrowser = {
        input_path = "${inputs.noctalia-community-templates}/qutebrowser/template.py";
        output_path = "${config.xdg.configHome}/qutebrowser/noctalia/colors.py";
        post_hook = lib.getExe reload;
      };
    };
}
