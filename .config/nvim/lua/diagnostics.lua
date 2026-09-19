vim.diagnostic.config({
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    virtual_lines = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    },
    virtual_text = {
        prefix = function(diag)
            local icons = { ERROR = " 󰅚 ", WARN = " 󰀪 ", INFO = " 󰋽 ", HINT = " 󰌶 " }
            return icons[vim.diagnostic.severity[diag.severity]]
        end,
    },
})
