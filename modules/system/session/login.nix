{
  flake.modules.nixos.login =
    { config, lib, ... }:
    {
      services.getty = {
        greetingLine = "<<< \\n >>>";
        helpLine = lib.mkForce "";

        loginOptions = "-p -- ${config.constants.username}";
        extraArgs = [ "--skip-login" ];
      };
    };
}
