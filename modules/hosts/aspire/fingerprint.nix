{
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      services.fprintd.package = pkgs.fprintd.override {
        libfprint = pkgs.libfprint-elan-press;
      };
    };
}
