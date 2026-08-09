{
    flake.nixosModules.base =
        { pkgs, ... }:
        {
            environment.systemPackages = with pkgs; [
                git
                vim
                wget
            ];
        };
}
