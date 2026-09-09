{
  flake.modules.homeManager.fzf =
    {
      config,
      lib,
      ...
    }:
    let
      files = "fd --type f --hidden --follow --exclude .git";
      dirs = "fd --type d --hidden --follow --exclude .git";

      theme = "${config.xdg.configHome}/fzf/themes/noctalia.sh";
    in
    {
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;

        defaultCommand = files;
        fileWidget.command = files;
        changeDirWidget.command = dirs;
      };

      programs.zsh.initContent = lib.mkOrder 700 ''
        if [ -z "$_NOCTALIA_FZF_THEME" ] && [ -r "${theme}" ]; then
          . "${theme}"
          export _NOCTALIA_FZF_THEME=1
        fi
      '';
    };
}
