{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim.autocmds = [
        {
          event = [ "BufReadPost" ];
          desc = "Restore cursor to last known position";
          callback = mkLuaInline ''
            function(ev)
                local buf = ev.buf
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
          event = [ "BufWritePre" ];
          desc = "Create missing parent directories on write";
          callback = mkLuaInline ''
            function(ev)
                if ev.match:match("^%w%w+://") then
                    return
                end
                local file = vim.uv.fs_realpath(ev.match) or ev.match
                vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
            end
          '';
        }

        {
          event = [ "FileType" ];
          pattern = [ "*" ];
          desc = "Prevent auto-comment on new lines";
          callback = mkLuaInline ''
            function()
                vim.opt_local.formatoptions:remove({ "c", "r", "o" })
            end
          '';
        }

        {
          event = [
            "BufEnter"
            "BufLeave"
            "WinEnter"
            "WinLeave"
          ];
          desc = "Cursor line only in the active window";
          callback = mkLuaInline ''
            function(ev)
                vim.opt_local.cursorline = vim.endswith(ev.event, "Enter")
            end
          '';
        }

        {
          event = [
            "InsertEnter"
            "InsertLeave"
          ];
          desc = "Relative numbers outside insert mode";
          callback = mkLuaInline ''
            function(ev)
                vim.opt_local.relativenumber = ev.event == "InsertLeave" and vim.wo.number
            end
          '';
        }

        {
          event = [ "TextYankPost" ];
          desc = "Flash yanked region";
          callback = mkLuaInline ''
            function()
                vim.hl.on_yank({ timeout = 150 })
            end
          '';
        }

        {
          event = [ "VimResized" ];
          desc = "Equalise window sizes on terminal resize";
          callback = mkLuaInline ''
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
