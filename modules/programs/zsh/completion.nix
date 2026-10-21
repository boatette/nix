{
  flake.modules.homeManager.zsh =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cache = "${config.xdg.cacheHome}/zsh";

      preview = "eza -1 --color=always --icons auto -- $realpath";
    in
    {
      programs.zsh.initContent = lib.mkMerge [
        (lib.mkOrder 690 ''
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        '')

        (lib.mkOrder 1000 ''
          zstyle ':completion:*' matcher-list \
            "" \
            'm:{a-z}={A-Za-z}' \
            'r:|[._-]=* r:|=*' \
            'l:|=* r:|=*'

          zstyle ':completion:*' complete-in-word true
          zstyle ':completion:*' special-dirs true
          zstyle ':completion:*' squeeze-slashes true
          zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
          zstyle ':completion:*' group-name ""
          zstyle ':completion:*:descriptions' format '[%d]'

          zstyle ':completion:*' use-cache true
          zstyle ':completion:*' cache-path ${cache}/zcompcache
          [[ -d ${cache} ]] || mkdir -p ${cache}

          zstyle ':completion:*' menu no

          zstyle ':fzf-tab:*' use-fzf-default-opts yes
          zstyle ':fzf-tab:*' switch-group '<' '>'
          zstyle ':fzf-tab:complete:cd:*' fzf-preview '${preview}'
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview '${preview}'
        '')
      ];
    };
}
