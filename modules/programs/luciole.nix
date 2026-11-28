{ inputs, ... }:
{
  flake-file.inputs.luciole.url = "github:noctalia-dev/luciole/cachix";

  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      imports = [ inputs.luciole.nixosModules.default ];

      assertions = [ (inputs.self.lib.glibcAssertion pkgs "luciole") ];

      programs.luciole.enable = true;

      nix.settings = {
        extra-substituters = [ "https://noctalia.cachix.org" ];
        extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };
    };
}
