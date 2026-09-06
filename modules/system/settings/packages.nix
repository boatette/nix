{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        curl
        git
        vim
        wget
      ];
    };
}
