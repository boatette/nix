{
  flake.modules.homeManager.dev =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        btop
        claude-code
        dust
        eza
        fd
        fzf
        jq
        lm_sensors
        ripgrep
        unzip
        zstd
      ];
    };
}
