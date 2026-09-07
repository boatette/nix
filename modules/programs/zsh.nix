{
  flake.modules.nixos.zsh.programs.zsh.enable = true;

  flake.modules.homeManager.zsh.programs = {
    zsh = {
      enable = true;

      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };
      syntaxHighlighting.enable = true;

      historySubstringSearch = {
        enable = true;
        searchUpKey = [
          "^[[A"
          "^P"
        ];
        searchDownKey = [
          "^[[B"
          "^N"
        ];
      };

      defaultKeymap = "viins";

      localVariables.KEYTIMEOUT = 1;

      setOptions = [
        "AUTO_PUSHD"
        "PUSHD_IGNORE_DUPS"
        "PUSHD_SILENT"

        "INTERACTIVE_COMMENTS"
        "HIST_REDUCE_BLANKS"

        "NO_FLOW_CONTROL"
        "NO_BEEP"
      ];

      history = {
        size = 100000;
        save = 100000;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
      };
    };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
      enableZshIntegration = true;
    };
  };
}
