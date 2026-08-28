{
  flake.modules.nixvim.core =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      autoGroups = {
        LargeFile.clear = true;
        RestoreCursor.clear = true;
        AutoMkdir.clear = true;
        NoAutoComment.clear = true;
        CursorLine.clear = true;
        RelativeNumbers.clear = true;
        ResizeSplits.clear = true;
      };

      autoCmd = [
        {
          event = "BufReadPre";
          group = "LargeFile";
          desc = "Disable expensive features for files over 1 MB";
          callback = mkRaw ''
            function()
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
                if ok and stats and stats.size > 1024 * 1024 then
                    vim.b.large_file = true
                    vim.cmd("syntax clear")
                    vim.opt_local.foldmethod = "manual"
                    vim.opt_local.spell = false
                    vim.opt_local.swapfile = false
                    vim.opt_local.undofile = false
                    vim.opt_local.signcolumn = "no"
                    vim.opt_local.statuscolumn = ""
                end
            end
          '';
        }

        {
          event = "BufReadPost";
          group = "RestoreCursor";
          desc = "Restore cursor to last known position";
          callback = mkRaw ''
            function(ev)
                local buf = ev.buf
                -- a commit message should open at the top, every time
                if vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo[buf].filetype) or vim.b[buf].restore_cursor then
                    return
                end
                vim.b[buf].restore_cursor = true
                local mark = vim.api.nvim_buf_get_mark(buf, '"')
                local lcount = vim.api.nvim_buf_line_count(buf)
                if mark[1] > 0 and mark[1] <= lcount then
                    pcall(vim.api.nvim_win_set_cursor, 0, mark)
                end
            end
          '';
        }

        {
          event = "BufWritePre";
          group = "AutoMkdir";
          desc = "Create missing parent directories on write";
          callback = mkRaw ''
            function(ev)
                -- oil://, fugitive:// and friends are not paths
                if ev.match:match("^%w%w+://") then
                    return
                end
                local file = vim.uv.fs_realpath(ev.match) or ev.match
                vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
            end
          '';
        }

        {
          event = "BufEnter";
          group = "NoAutoComment";
          desc = "Prevent auto-comment on new lines";
          callback = mkRaw ''
            function()
                vim.opt.formatoptions:remove({ "c", "r", "o" })
            end
          '';
        }

        {
          event = [
            "WinEnter"
            "BufEnter"
          ];
          group = "CursorLine";
          desc = "Cursor line in active window";
          callback = mkRaw ''
            function()
                if not vim.b.large_file then
                    vim.opt_local.cursorline = true
                end
            end
          '';
        }
        {
          event = [
            "WinLeave"
            "BufLeave"
          ];
          group = "CursorLine";
          desc = "No cursor line in inactive window";
          callback = mkRaw ''
            function()
                vim.opt_local.cursorline = false
            end
          '';
        }

        {
          event = "InsertEnter";
          group = "RelativeNumbers";
          desc = "Disable relative numbers in insert mode";
          callback = mkRaw ''
            function()
                vim.opt.relativenumber = false
            end
          '';
        }
        {
          event = "InsertLeave";
          group = "RelativeNumbers";
          desc = "Enable relative numbers in normal mode";
          callback = mkRaw ''
            function()
                vim.opt.relativenumber = true
            end
          '';
        }

        {
          event = "TextYankPost";
          desc = "Flash yanked region";
          callback = mkRaw ''
            function()
                vim.hl.on_yank({ timeout = 150 })
            end
          '';
        }

        {
          event = "VimResized";
          group = "ResizeSplits";
          desc = "Equalise window sizes on terminal resize";
          callback = mkRaw ''
            function()
                local tab = vim.fn.tabpagenr()
                vim.cmd("tabdo wincmd =")
                vim.cmd("tabnext " .. tab)
            end
          '';
        }
      ];
    };
}
