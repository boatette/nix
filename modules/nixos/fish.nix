{ lib, ... }:

{
    programs.fish.enable = true;

    environment.shellAliases = lib.mkForce { };
}
