{ username, ... }:

{
    imports = [
        ./backup.nix
        ./dotfiles.nix
        ./env.nix
        ./packages.nix
        ./shell.nix
        ./theme.nix
        ./neovim
    ];

    home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "26.05";
    };
}
