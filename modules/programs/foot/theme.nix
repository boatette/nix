{
  flake.modules.homeManager.foot =
    { pkgs, ... }:
    {
      programs.foot.settings.main.include = "${pkgs.foot.themes}/share/foot/themes/rose-pine";
    };
}
