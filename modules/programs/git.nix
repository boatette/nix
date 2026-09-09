{
  flake.modules.homeManager.git =
    { config, ... }:
    {
      programs.git = {
        enable = true;

        settings = {
          user = {
            name = config.constants.username;
            inherit (config.constants) email;
          };

          init.defaultBranch = "master";

          push = {
            autoSetupRemote = true;
            followTags = true;
          };

          pull.rebase = true;

          rebase = {
            autoStash = true;
            updateRefs = true;
          };

          rerere.enabled = true;

          merge.conflictStyle = "zdiff3";

          diff = {
            algorithm = "histogram";
            colorMoved = "default";
          };

          fetch = {
            prune = true;
            pruneTags = true;
          };

          branch.sort = "-committerdate";
          tag.sort = "-version:refname";
          column.ui = "auto";
        };

        ignores = [
          "/result"
          ".direnv/"
        ];

        maintenance = {
          enable = true;
          repositories = [ config.constants.flakeDir ];
        };
      };
    };
}
