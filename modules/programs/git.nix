{ inputs, ... }:
{
  flake.modules.homeManager.boatette = {
    programs.git = {
      enable = true;

      settings = {
        user = {
          name = inputs.self.constants.username;
          inherit (inputs.self.constants) email;
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
        repositories = [ inputs.self.constants.flakeDir ];
      };
    };
  };
}
