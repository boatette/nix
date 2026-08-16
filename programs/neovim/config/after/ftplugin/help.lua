require("ft").utility_window()

if vim.bo.buftype == "help" then
    vim.cmd("wincmd L")
end
