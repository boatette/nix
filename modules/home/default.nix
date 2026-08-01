{ username, ... }:

{
    imports = [
        ./dotfiles.nix
        ./env.nix
        ./neovim
        ./packages.nix
        ./shell.nix
        ./theme.nix
    ];

    home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "26.05";
    };
}
