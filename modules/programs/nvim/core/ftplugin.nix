{
  flake.modules.nvf.core =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;

      mkFt = pattern: desc: body: {
        event = [ "FileType" ];
        group = "Ftplugin";
        inherit pattern desc;
        callback = mkLuaInline ''
          function(ev)
          ${body}
          end
        '';
      };

      utilityWindow = /* lua */ ''
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close" })
      '';

      prose = /* lua */ ''
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
      '';

      twoSpace = /* lua */ ''
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
      '';
    in
    {
      vim = {
        augroups = [ { name = "Ftplugin"; } ];

        autocmds = [
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
            /* lua */ ''
              vim.opt_local.conceallevel = 0
            ''
          )

          (mkFt [ "help" ] "Open :help in a vertical split" /* lua */ ''
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
    };
}
