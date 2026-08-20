{
  flake.modules.nixos.desktop = {
    services.fprintd.enable = true;

    programs.noctalia-greeter.settings.auth.allow_empty_password = true;
  };
}
