let
  flakeDir = "$HOME/nix";

  posixFunctions = ''
    mkcd() { mkdir -p -- "$1" && cd "$1"; }
    cl() { cd "$1" && ls; }
  '';
in

{
  flake.modules.nixos.base =
    { lib, ... }:
    {
      programs.fish.enable = true;
      environment.shellAliases = lib.mkForce { };
    };

  flake.modules.homeManager.dev =
    { pkgs, lib, ... }:
    {
      home.shellAliases = import ./_aliases.nix { inherit flakeDir; };

      home.packages = import ./_scripts.nix {
        inherit pkgs;
        inherit flakeDir;
      };

      programs = {
        starship.enable = true;

        zoxide = {
          enable = true;
          options = [ "--cmd cd" ];

          enableFishIntegration = false;
        };

        bash = {
          enable = true;
          enableCompletion = true;
          initExtra = posixFunctions;
        };

        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          initContent = posixFunctions;
        };

        fish = {
          enable = true;

          interactiveShellInit = lib.mkMerge [
            ''
              set -g fish_greeting ""
              set -g fish_key_bindings fish_vi_key_bindings
              set -g fish_escape_delay_ms 10

              if test -f $HOME/.fish_profile
                  source $HOME/.fish_profile
              end
            ''

            (lib.mkAfter ''
              ${lib.getExe pkgs.zoxide} init fish --cmd cd | source
            '')
          ];

          functions = {
            mkcd = {
              description = "mkdir -p, then cd into it";
              body = "mkdir -p -- $argv[1]; and cd $argv[1]";
            };

            cl = {
              description = "cd, then ls";
              body = "cd $argv[1]; and ls";
            };

            history = {
              description = "history with timestamps";
              body = "builtin history --show-time='%F %T ' $argv";
            };

            fish_user_key_bindings = {
              description = "emacs-style rescues on top of vi mode";
              body = ''
                for mode in insert default
                    bind -M $mode ctrl-a beginning-of-line
                    bind -M $mode ctrl-e end-of-line
                    bind -M $mode ctrl-r history-pager
                end

                bind -M insert ctrl-w backward-kill-word
                bind -M insert ctrl-u backward-kill-line
                bind -M insert ctrl-f accept-autosuggestion

                bind -M insert ! __history_previous_command
                bind -M insert '$' __history_previous_command_arguments
              '';
            };

            __history_previous_command = {
              description = "expand ! to the previous command";
              body = ''
                switch (commandline -t)
                    case "!"
                        commandline -t $history[1]
                        commandline -f repaint
                    case "*"
                        commandline -i !
                end
              '';
            };

            __history_previous_command_arguments = {
              description = "expand !$ to the last argument";
              body = ''
                switch (commandline -t)
                    case "!"
                        commandline -t ""
                        commandline -f history-token-search-backward
                    case "*"
                        commandline -i '$'
                end
              '';
            };
          };
        };
      };
    };
}
