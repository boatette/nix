{
  flake.modules.nixos.login =
    { config, ... }:
    {
      services.getty = {
        greetingLine = "<<< \\n >>>";
        helpLine = "";

        loginOptions = "-p -- ${config.constants.username}";
        extraArgs = [ "--skip-login" ];
      };
    };
}
