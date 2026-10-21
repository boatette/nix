{ inputs, ... }:
{
  flake-file.inputs.rose-pine-fzf = {
    url = "github:rose-pine/fzf";
    flake = false;
  };

  flake.modules.homeManager.fzf =
    { lib, ... }:
    let
      files = "fd --type f --hidden --follow --exclude .git";
      dirs = "fd --type d --hidden --follow --exclude .git";
    in
    {
      programs.fzf = {
        enable = true;

        defaultCommand = files;
        fileWidget.command = files;
        changeDirWidget.command = dirs;
      };

      programs.zsh.initContent = lib.mkOrder 700 ''
        . ${inputs.rose-pine-fzf}/dist/rose-pine.sh
      '';
    };
}
