require("snacks").setup({
    bigfile = {},
    bufdelete = {},
    indent = { animate = { enabled = false } },
    lazygit = { win = { style = "float", position = "float" } },
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
                    box = "vertical",
                    backdrop = true,
                    row = 1000,
                    width = 0,
                    height = 0.4,
                    border = "top",
                    title = " {title} {live} {flags}",
                    title_pos = "left",
                    {
                        box = "horizontal",
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                    },
                    { win = "input", height = 1 },
                },
            },
        },
        sources = {
            files = { hidden = true, follow = true },
        },
    },
    quickfile = {},
    terminal = { win = { position = "bottom" } },

    animate = { enabled = false },
    dashboard = { enabled = false },
    debug = { enabled = false },
    dim = { enabled = false },
    explorer = { enabled = false },
    gh = { enabled = false },
    git = { enabled = false },
    gitbrowse = { enabled = false },
    health = { enabled = false },
    image = { enabled = false },
    input = { enabled = false },
    keymap = { enabled = false },
    profiler = { enabled = false },
    rename = { enabled = false },
    scope = { enabled = false },
    scratch = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    toggle = { enabled = false },
    util = { enabled = false },
    win = { enabled = false },
    words = { enabled = false },
    zen = { enabled = false },
})

-- INFO: Removes undefined global warning
local Snacks = require("snacks")

local map = vim.keymap.set

map("n", "<leader><space>", function()
    Snacks.picker.smart()
end, { desc = "Smart find (files/recent)" })
map("n", "<leader>ff", function()
    Snacks.picker.files()
end, { desc = "Find files" })
map("n", "<leader>fr", function()
    Snacks.picker.recent()
end, { desc = "Recent files" })
map("n", "<leader>fR", function()
    Snacks.picker.recent({ filter = { cwd = true } })
end, { desc = "Recent files (cwd)" })
map("n", "<leader>sg", function()
    Snacks.picker.grep()
end, { desc = "Live grep" })
map({ "n", "x" }, "<leader>sw", function()
    Snacks.picker.grep_word()
end, { desc = "Grep word under cursor" })
map("n", "<leader>fb", function()
    Snacks.picker.buffers()
end, { desc = "Buffers" })
map("n", "<leader>sh", function()
    Snacks.picker.help()
end, { desc = "Help tags" })
map("n", "<leader>sk", function()
    Snacks.picker.keymaps()
end, { desc = "Keymaps" })
map("n", "<leader>fc", function()
    Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Config files" })
map("n", "<leader>uc", function()
    Snacks.picker.colorschemes()
end, { desc = "Colorschemes" })
map("n", "<leader>sm", function()
    Snacks.picker.marks()
end, { desc = "Marks" })
map("n", "<leader>sj", function()
    Snacks.picker.jumps()
end, { desc = "Jump list" })
map("n", "<leader>s'", function()
    Snacks.picker.registers()
end, { desc = "Registers" })
map("n", "<leader>fs", function()
    Snacks.picker.lsp_symbols()
end, { desc = "LSP document symbols" })
map("n", "<leader>fS", function()
    Snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP workspace symbols" })

map("n", "<leader>gc", function()
    Snacks.picker.git_log()
end, { desc = "Git log" })
map("n", "<leader>gF", function()
    Snacks.picker.git_status()
end, { desc = "Git status" })
map("n", "<leader>go", function()
    Snacks.gitbrowse()
end, { desc = "Git browse (open in browser)" })
map("n", "<leader>gg", function()
    Snacks.lazygit()
end, { desc = "Lazygit" })
map("n", "<leader>gl", function()
    Snacks.lazygit.log()
end, { desc = "Lazygit log" })

map({ "n", "t" }, "<C-`>", function()
    Snacks.terminal()
end, { desc = "Toggle terminal" })
map("n", "<leader>ot", function()
    Snacks.terminal()
end, { desc = "Toggle terminal" })

map("n", "<leader>un", function()
    Snacks.notifier.hide()
end, { desc = "Dismiss notifications" })
map("n", "<leader>uN", function()
    Snacks.picker.notifications()
end, { desc = "Browse notifications" })

map("n", "<leader>bd", function()
    Snacks.bufdelete()
end, { desc = "Delete buffer" })
map("n", "<leader>bD", function()
    Snacks.bufdelete({ force = true })
end, { desc = "Delete buffer (force)" })
