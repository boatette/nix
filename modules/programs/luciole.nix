{ inputs, ... }:
{
  flake-file.inputs.luciole.url = "github:noctalia-dev/luciole/cachix";

  flake.modules.nixos.luciole =
    { pkgs, ... }:
    {
      imports = [ inputs.luciole.nixosModules.default ];

      assertions = [ (inputs.self.lib.glibcAssertion pkgs "luciole") ];

      programs.luciole.enable = true;
    };
}
