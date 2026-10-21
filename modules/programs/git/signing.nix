{
  flake.modules.homeManager.git =
    { config, ... }:
    let
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIINQKEWxBhhxYa3EW9/1o9RG3m/i9dvdVaExj9fY2GFV";
    in
    {
      programs.git.signing = {
        format = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        signByDefault = true;

        allowedSigners = "${config.constants.email} ${publicKey}";
      };
    };
}
