{
  flake.modules.homeManager.shell.programs.starship = {
    enable = true;

    settings = {
      add_newline = false;

      format = "$directory$git_branch$git_commit$git_state$git_status$package$character\n";
      right_format = "$cmd_duration$jobs$sudo";

      character.vimcmd_symbol = "[](bold green)";
    };
  };
}
