local M = {}

function M.utility_window()
    vim.bo.buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true, desc = "Close" })
end

function M.prose()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true

    vim.opt_local.spell = true
end

function M.two_space()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
end

return M
