{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    let
      inherit (inputs.self.lib.colours) hex;
    in
    {
      programs.starship = {
        enable = true;

        settings = {
          add_newline = false;

          format = "$directory$git_branch$git_commit$git_state$git_status$package$character\n";
          right_format = "$cmd_duration$jobs$sudo";

          character.vimcmd_symbol = "[](bold green)";
          package.style = "bold yellow";

          palette = "rose-pine";
          palettes.rose-pine = {
            red = hex "love";
            green = hex "pine";
            yellow = hex "gold";
            blue = hex "foam";
            purple = hex "iris";
            cyan = hex "rose";
          };
        };
      };
    };
}
