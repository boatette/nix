local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

autocmd("BufReadPre", {
    group = augroup("LargeFile", { clear = true }),
    callback = function()
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
    end,
    desc = "Disable expensive features for files over 1 MB",
})

autocmd("BufReadPost", {
    group = augroup("RestoreCursor", { clear = true }),
    callback = function(ev)
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
    end,
    desc = "Restore cursor to last known position",
})

autocmd("BufWritePre", {
    group = augroup("AutoMkdir", { clear = true }),
    callback = function(ev)
        if ev.match:match("^%w%w+://") then
            return
        end
        local file = vim.uv.fs_realpath(ev.match) or ev.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
    desc = "Create missing parent directories on write",
})

autocmd("BufEnter", {
    group = augroup("NoAutoComment", { clear = true }),
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
    desc = "Prevent auto-comment on new lines",
})

local cur_group = augroup("CursorLine", { clear = true })
autocmd({ "WinEnter", "BufEnter" }, {
    group = cur_group,
    callback = function()
        if not vim.b.large_file then
            vim.opt_local.cursorline = true
        end
    end,
    desc = "Cursor line in active window",
})
autocmd({ "WinLeave", "BufLeave" }, {
    group = cur_group,
    callback = function()
        vim.opt_local.cursorline = false
    end,
    desc = "No cursor line in inactive window",
})

local rnu_group = augroup("RelativeNumbers", { clear = true })
autocmd("InsertEnter", {
    group = rnu_group,
    callback = function()
        vim.opt.relativenumber = false
    end,
    desc = "Disable relative numbers in insert mode",
})
autocmd("InsertLeave", {
    group = rnu_group,
    callback = function()
        vim.opt.relativenumber = true
    end,
    desc = "Enable relative numbers in normal mode",
})

autocmd("TextYankPost", {
    callback = function()
        vim.hl.hl_op({ timeout = 150 })
    end,
    desc = "Flash yanked region",
})

autocmd("TextPutPost", {
    callback = function()
        vim.hl.hl_op({ timeout = 150 })
    end,
    desc = "Flash pasted region",
})

autocmd("VimResized", {
    group = augroup("ResizeSplits", { clear = true }),
    callback = function()
        local tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. tab)
    end,
    desc = "Equalise window sizes on terminal resize",
})
