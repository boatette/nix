{
  flake.modules.nvf.nvim =
    { lib, ... }:
    {
      vim.binds.whichKey = {
        enable = true;

        # forced, as nvf's modules label maps that vendoredKeymaps = false never creates
        register = lib.mkForce {
          "<leader>b" = "+Buffer";
          "<leader>c" = "+Code";
          "<leader>d" = "+Debug";
          "<leader>f" = "+Find";
          "<leader>g" = "+Git";
          "<leader>m" = "+Markdown";
          "<leader>n" = "+NixOS";
          "<leader>o" = "+Open";
          "<leader>r" = "+Rust";
          "<leader>s" = "+Search";
          "<leader>t" = "+Test";
          "<leader>u" = "+UI";
          "<leader>w" = "+Window";
          "<leader>x" = "+Trouble";
        };

        setupOpts.preset = "helix";
      };
    };
}
