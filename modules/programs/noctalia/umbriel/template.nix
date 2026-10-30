{
  # noctalia's builtin umbriel template, less [colors.title_bar]: nixpkgs' umbriel predates title
  # bars and rejects the key. Its apply.sh hook only adds the include, which include.nix does
  flake.modules.homeManager.noctalia =
    { config, pkgs, ... }:
    {
      programs.noctalia.settings.theme.templates.user.umbriel = {
        input_path = "${pkgs.runCommand "noctalia-umbriel-template" { } ''
          sed '/^\[colors\.title_bar\]/,/^$/d' \
            ${config.programs.noctalia.package}/share/noctalia/assets/templates/umbriel/umbriel.toml > $out
        ''}";
        output_path = "$XDG_CONFIG_HOME/umbriel/noctalia.toml";
      };
    };
}
