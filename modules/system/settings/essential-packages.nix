{
  flake.modules.nixos.essential-packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        git
        vim
        wget
      ];
    };
}
