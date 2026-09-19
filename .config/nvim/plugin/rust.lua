vim.pack.add({ "https://github.com/mrcjkb/rustaceanvim" })

vim.g.rustaceanvim = function()
    return {
        dap = {
            adapter = { command = "lldb-dap", name = "lldb", type = "executable" },
        },
        server = {
            default_settings = {
                ["rust-analyzer"] = {
                    cargo = { allFeatures = true },
                    check = { command = "clippy" },
                    checkOnSave = true,
                    inlayHints = { enable = true },
                    procMacro = { enable = true },
                },
            },
        },
        tools = { hover_actions = { replace_builtin_hover = true } },
    }
end
