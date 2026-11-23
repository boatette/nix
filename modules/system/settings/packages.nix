{
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        curl
        git
        wget
      ];
    };
}
