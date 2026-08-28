{
  flake.modules.nixvim.core =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;

      mkFt = pattern: desc: body: {
        event = "FileType";
        group = "Ftplugin";
        inherit pattern desc;
        callback = mkRaw ''
          function(ev)
          ${body}
          end
        '';
      };

      utilityWindow = ''
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close" })
      '';

      prose = ''
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
      '';

      twoSpace = ''
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
      '';
    in
    {
      autoGroups.Ftplugin.clear = true;

      autoCmd = [
        (mkFt [
          "checkhealth"
          "help"
          "lazygit"
          "lspinfo"
          "man"
          "notify"
          "qf"
          "query"
        ] "Utility window: unlisted, q to close" utilityWindow)

        (mkFt [
          "gitcommit"
          "markdown"
          "text"
        ] "Prose: wrap, linebreak, spell" prose)

        (mkFt [
          "dart"
          "json"
          "json5"
          "jsonc"
          "nix"
        ] "Two-space indent" twoSpace)

        (mkFt
          [
            "json"
            "json5"
            "jsonc"
          ]
          "Show quotes in JSON"
          ''
            vim.opt_local.conceallevel = 0
          ''
        )

        (mkFt [ "oil" ] "No colourcolumn in oil" ''
          vim.opt_local.colorcolumn = ""
        '')

        (mkFt [ "help" ] "Open :help in a vertical split" ''
          local function vertical()
              if vim.bo.buftype == "help" and vim.api.nvim_win_get_config(0).relative == "" then
                  vim.cmd("wincmd L")
              end
          end

          local group = vim.api.nvim_create_augroup("HelpVertical", { clear = false })
          vim.api.nvim_clear_autocmds({ group = group, buffer = ev.buf })
          vim.api.nvim_create_autocmd("BufWinEnter", {
              group = group,
              buffer = ev.buf,
              callback = vertical,
              desc = "Open :help in a vertical split",
          })

          vertical()
        '')
      ];
    };
}
