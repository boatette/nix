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

      filePreview = "bat --color=always --style=numbers --line-range=:300 -- {}";
      dirPreview = "eza -T -L 2 --color=always --icons always -- {}";
    in
    {
      programs.fzf = {
        enable = true;

        defaultCommand = files;
        fileWidget = {
          command = files;
          options = [ "--preview '${filePreview}'" ];
        };
        changeDirWidget = {
          command = dirs;
          options = [ "--preview '${dirPreview}'" ];
        };
      };

      programs.zsh.initContent = lib.mkMerge [
        (lib.mkOrder 700 ''
          . ${inputs.rose-pine-fzf}/dist/rose-pine.sh
        '')

        ''
          fcd() {
            local dir

            dir=$(${dirs} . "''${1:-.}" | fzf --preview '${dirPreview}') || return

            builtin cd -- "$dir"
          }

          fv() {
            local -a picked

            picked=(''${(f)"$(${files} . "''${1:-.}" | fzf --multi --preview '${filePreview}')"})

            (( $#picked )) && nvim -- "''${picked[@]}"
          }

          frg() {
            local rg='rg --column --line-number --no-heading --color=always --smart-case'
            local hit file line

            hit=$(fzf --ansi --disabled --query "$*" \
              --bind "start:reload:$rg -- {q} || true" \
              --bind "change:reload:$rg -- {q} || true" \
              --delimiter : \
              --preview 'bat --color=always --style=numbers --highlight-line {2} -- {1}' \
              --preview-window '+{2}/2') || return

            file=''${hit%%:*}
            line=''${''${hit#*:}%%:*}

            nvim "+$line" -- "$file"
          }

          fkill() {
            local -a pids

            pids=(''${(f)"$(ps -u "$USER" -o pid,args |
              fzf --multi --header-lines 1 --prompt 'kill > ' |
              awk '{print $1}')"})

            (( $#pids )) && kill -"''${1:-TERM}" "''${pids[@]}"
          }

          fgb() {
            local branch

            branch=$(git for-each-ref --sort=-committerdate --exclude 'refs/remotes/*/HEAD' \
              --format '%(refname:short)' refs/heads refs/remotes |
              fzf --preview 'git log --oneline --graph --color=always -30 {}') || return

            if git show-ref --verify --quiet "refs/heads/$branch"; then
              git switch "$branch"
            else
              git switch --track "$branch"
            fi
          }

          fgl() {
            git log --oneline --color=always "$@" |
              fzf --ansi --no-sort \
                --preview 'git show --stat --patch --color=always {1}' \
                --bind 'enter:execute(git show {1})'
          }

          fga() {
            local -a picked

            picked=(''${(f)"$(git ls-files --modified --others --exclude-standard --deduplicate |
              fzf --multi --preview 'git ls-files --error-unmatch -- {} >/dev/null 2>&1 && git diff --color=always -- {} || bat --color=always -- {}')"})

            (( $#picked )) && git add -- "''${picked[@]}"
          }
        ''
      ];
    };
}
