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

return M
