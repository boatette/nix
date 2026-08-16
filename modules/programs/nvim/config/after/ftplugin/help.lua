require("ft").utility_window()

local function vertical()
    if vim.bo.buftype == "help" and vim.api.nvim_win_get_config(0).relative == "" then
        vim.cmd("wincmd L")
    end
end

local group = vim.api.nvim_create_augroup("HelpVertical", { clear = false })
vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    buffer = 0,
    callback = vertical,
    desc = "Open :help in a vertical split",
})

vertical()
