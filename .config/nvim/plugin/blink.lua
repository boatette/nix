vim.pack.add({
    "https://github.com/nvim-mini/mini.snippets",
    "https://github.com/saghen/blink.lib",
    "https://github.com/saghen/blink.cmp",
})

local snippets = require("mini.snippets")
snippets.setup({
    snippets = {
        snippets.gen_loader.from_runtime("global.json"),
        snippets.gen_loader.from_lang(),
    },
})

local cmp = require("blink.cmp")
cmp.build():wait(60000)
cmp.setup({
    cmdline = { keymap = { preset = "none" } },
    completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },
        list = { selection = { preselect = true, auto_insert = true } },
        menu = {
            auto_show = true,
            draw = {
                columns = { { "source_name" }, { "kind_icon" }, { "label" }, { "kind" } },
            },
        },
        trigger = { prefetch_on_insert = true, show_in_snippet = false },
    },
    fuzzy = { implementation = "prefer_rust" },
    keymap = { preset = "super-tab" },
    signature = { enabled = true },
    snippets = { preset = "mini_snippets" },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {},
    },
})
