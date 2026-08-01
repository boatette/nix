-- vim.api.nvim_create_autocmd("PackChanged", {
--     callback = function(ev)
--         local name, kind = ev.data.spec.name, ev.data.kind
--         if name == "blink.cmp" and (kind == "install" or kind == "update") then
--             if not ev.data.active then
--                 vim.cmd.packadd("blink.cmp")
--             end
--             require("blink.cmp").build():pwait(300000)
--         end
--     end,
--     desc = "vim.pack post-change hooks",
-- })

vim.pack.add({
    "https://github.com/nvim-mini/mini.snippets",
    "https://github.com/saghen/blink.lib",
    "https://github.com/saghen/blink.cmp",
})

require("mini.snippets").setup({
    snippets = { require("mini.snippets").gen_loader.from_lang() },
})

require('blink.cmp').build():pwait()
require("blink.cmp").setup({
    completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true },
        ghost_text = { enabled = true },
        list = { selection = { preselect = true, auto_insert = true } },
        menu = {
            draw = {
                columns = {
                    { "source_name" },
                    { "kind_icon" },
                    { "label" },
                    { "kind" },
                },
            },
        },
        trigger = {
            prefetch_on_insert = true,
            show_in_snippet = false,
        },
    },
    keymap = { preset = "super-tab" },
    snippets = { preset = "mini_snippets" },
    signature = { enabled = true },
})
