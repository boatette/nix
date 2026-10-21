{ inputs, ... }:
{
  flake-file.inputs.rose-pine-starship = {
    url = "github:rose-pine/starship";
    flake = false;
  };

  flake.modules.homeManager.starship =
    let
      inherit (fromTOML (builtins.readFile "${inputs.rose-pine-starship}/rose-pine.toml")) palettes;
      rp = palettes.rose-pine;
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
            red = rp.love;
            green = rp.pine;
            yellow = rp.gold;
            blue = rp.foam;
            purple = rp.iris;
            cyan = rp.rose;
          };
        };
      };
    };
}
