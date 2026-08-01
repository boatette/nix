vim.g.rustaceanvim = {
    tools = { hover_actions = { replace_builtin_hover = true } },
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                cargo = { allFeatures = true },
                checkOnSave = true,
                check = { command = "clippy" },
                inlayHints = { enable = true },
                procMacro = { enable = true },
            },
        },
    },
    dap = {
        adapter = {
            type = "server",
            port = "${port}",
            executable = {
                command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
                args = { "--port", "${port}" },
            },
        },
    },
}
