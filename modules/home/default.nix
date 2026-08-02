{ username, ... }:

{
    imports = [
        ./backup.nix
        ./dotfiles.nix
        ./env.nix
        ./git.nix
        ./packages.nix
        ./shell.nix
        ./theme.nix
        ./neovim
        ./scripts
    ];

    home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "26.05";
    };
}
