{

  flake.modules.nixos.fingerprint.services.fprintd.enable = true;

  flake.modules.nixos.greeter.programs.noctalia-greeter.settings.auth.allow_empty_password = true;
}
