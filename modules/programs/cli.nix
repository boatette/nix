{
  flake.modules.homeManager.base =
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
