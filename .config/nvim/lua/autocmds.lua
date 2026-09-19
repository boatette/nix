local function augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

local ftplugin = augroup("Ftplugin")

vim.api.nvim_create_autocmd("FileType", {
    group = ftplugin,
    pattern = { "checkhealth", "help", "lazygit", "lspinfo", "man", "notify", "qf", "query" },
    desc = "Utility window: unlisted, q to close",
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close" })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = ftplugin,
    pattern = { "gitcommit", "markdown", "text" },
    desc = "Prose: wrap, linebreak, spell",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = ftplugin,
    pattern = { "dart", "json", "json5", "jsonc", "nix" },
    desc = "Two-space indent",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = ftplugin,
    pattern = { "json", "json5", "jsonc" },
    desc = "Show quotes in JSON",
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = ftplugin,
    pattern = "help",
    desc = "Open :help in a vertical split",
    callback = function(ev)
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
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("RestoreCursor"),
    desc = "Restore cursor to last known position",
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
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup("AutoMkdir"),
    desc = "Create missing parent directories on write",
    callback = function(ev)
        if ev.match:match("^%w%w+://") then
            return
        end
        local file = vim.uv.fs_realpath(ev.match) or ev.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("NoAutoComment"),
    pattern = "*",
    desc = "Prevent auto-comment on new lines",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

local cursorline = augroup("CursorLine")

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = cursorline,
    desc = "Cursor line in active window",
    callback = function()
        vim.opt_local.cursorline = true
    end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = cursorline,
    desc = "No cursor line in inactive window",
    callback = function()
        vim.opt_local.cursorline = false
    end,
})

local relativenumbers = augroup("RelativeNumbers")

vim.api.nvim_create_autocmd("InsertEnter", {
    group = relativenumbers,
    desc = "Disable relative numbers in insert mode",
    callback = function()
        vim.opt_local.relativenumber = false
    end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
    group = relativenumbers,
    desc = "Enable relative numbers in normal mode",
    callback = function()
        vim.opt_local.relativenumber = true
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Flash yanked region",
    callback = function()
        vim.hl.on_yank({ timeout = 150 })
    end,
})

vim.api.nvim_create_autocmd("VimResized", {
    group = augroup("ResizeSplits"),
    desc = "Equalise window sizes on terminal resize",
    callback = function()
        local tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. tab)
    end,
})
