{ inputs, ... }:
{
  flake-file.inputs.rose-pine-delta = {
    url = "github:rose-pine/delta";
    flake = false;
  };

  flake.modules.homeManager.git = {
    programs.git.includes = [ { path = "${inputs.rose-pine-delta}/dist/rose-pine.gitconfig"; } ];

    programs.delta = {
      enable = true;
      enableGitIntegration = true;

      options = {
        features = "rose-pine";
        syntax-theme = "rose-pine";

        navigate = true;
        line-numbers = true;
        hyperlinks = true;
      };
    };
  };
}
