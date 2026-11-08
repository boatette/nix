{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    let
      inherit (inputs.self.lib.nvim) mod;

      rebuild = inputs.self.lib.rebuild inputs.self.constants.flakeDir;

      nixosRebuild =
        key: cmd: desc:
        mod "n" key "snacks" ''terminal("${cmd}", { interactive = true })'' desc;
    in
    {
      vim.keymaps = [
        (nixosRebuild "<leader>ns" (rebuild.os "switch") "Rebuild switch")
        (nixosRebuild "<leader>nt" (rebuild.os "test") "Rebuild test")
        (nixosRebuild "<leader>nb" (rebuild.os "boot") "Rebuild boot")
        (nixosRebuild "<leader>nd" rebuild.dryBuild "Rebuild dry-build")
      ];
    };
}
