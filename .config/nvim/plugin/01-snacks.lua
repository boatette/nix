vim.pack.add({ "https://github.com/folke/snacks.nvim" })

require("snacks").setup({
    bigfile = { size = 1048576 },
    bufdelete = {},
    indent = { animate = { enabled = false } },
    lazygit = { win = { position = "float", style = "float" } },
    notifier = {
        style = function(buf, notif, ctx)
            ctx.opts.border = "top"
            ctx.opts.title = { { " " .. notif.icon .. (notif.title or ""), ctx.hl.title } }
            ctx.opts.title_pos = "left"

            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notif.msg, "\n"))
        end,
        top_down = false,
    },
    picker = {
        layout = "custom",
        layouts = {
            custom = {
                layout = {
                    backdrop = true,
                    border = "top",
                    box = "vertical",
                    height = 0.4,
                    row = 1000,
                    title = " {title} {live} {flags}",
                    title_pos = "left",
                    width = 0,
                    {
                        box = "horizontal",
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", border = "left", width = 0.6 },
                    },
                    { win = "input", height = 1 },
                },
            },
        },
        sources = { files = { follow = true, hidden = true } },
    },
    quickfile = {},
    terminal = { win = { position = "bottom" } },
})

vim.keymap.set("n", "<leader><space>", function()
    require("snacks").picker.smart()
end, { desc = "Smart find (files/recent)" })
vim.keymap.set("n", "<leader>ff", function()
    require("snacks").picker.files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fr", function()
    require("snacks").picker.recent()
end, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fR", function()
    require("snacks").picker.recent({ filter = { cwd = true } })
end, { desc = "Recent files (cwd)" })
vim.keymap.set("n", "<leader>sg", function()
    require("snacks").picker.grep()
end, { desc = "Live grep" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
    require("snacks").picker.grep_word()
end, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>fb", function()
    require("snacks").picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>sh", function()
    require("snacks").picker.help()
end, { desc = "Help tags" })
vim.keymap.set("n", "<leader>sk", function()
    require("snacks").picker.keymaps()
end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fc", function()
    require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Config files" })
vim.keymap.set("n", "<leader>uc", function()
    require("snacks").picker.colorschemes()
end, { desc = "Colorschemes" })
vim.keymap.set("n", "<leader>sm", function()
    require("snacks").picker.marks()
end, { desc = "Marks" })
vim.keymap.set("n", "<leader>sj", function()
    require("snacks").picker.jumps()
end, { desc = "Jump list" })
vim.keymap.set("n", "<leader>s'", function()
    require("snacks").picker.registers()
end, { desc = "Registers" })
vim.keymap.set("n", "<leader>fs", function()
    require("snacks").picker.lsp_symbols()
end, { desc = "LSP document symbols" })
vim.keymap.set("n", "<leader>fS", function()
    require("snacks").picker.lsp_workspace_symbols()
end, { desc = "LSP workspace symbols" })
vim.keymap.set("n", "<leader>gc", function()
    require("snacks").picker.git_log()
end, { desc = "Git log" })
vim.keymap.set("n", "<leader>gF", function()
    require("snacks").picker.git_status()
end, { desc = "Git status" })
vim.keymap.set("n", "<leader>go", function()
    require("snacks").gitbrowse()
end, { desc = "Git browse (open in browser)" })
vim.keymap.set("n", "<leader>gg", function()
    require("snacks").lazygit()
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>gl", function()
    require("snacks").lazygit.log()
end, { desc = "Lazygit log" })
vim.keymap.set({ "n", "t" }, "<C-`>", function()
    require("snacks").terminal()
end, { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>ot", function()
    require("snacks").terminal()
end, { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>un", function()
    require("snacks").notifier.hide()
end, { desc = "Dismiss notifications" })
vim.keymap.set("n", "<leader>uN", function()
    require("snacks").picker.notifications()
end, { desc = "Browse notifications" })
vim.keymap.set("n", "<leader>bd", function()
    require("snacks").bufdelete()
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bD", function()
    require("snacks").bufdelete({ force = true })
end, { desc = "Delete buffer (force)" })
