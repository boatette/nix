vim.pack.add({
    "https://github.com/famiu/bufdelete.nvim",
    "https://github.com/akinsho/bufferline.nvim",
})

local bufferline = require("bufferline")

bufferline.setup({
    highlights = {},
    options = {
        always_show_bufferline = true,
        auto_toggle_bufferline = true,
        buffer_close_icon = " 󰅖 ",
        close_command = function(bufnum)
            require("bufdelete").bufdelete(bufnum, false)
        end,
        close_icon = "  ",
        color_icons = true,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = " "
            for e, n in pairs(diagnostics_dict) do
                local sym = e == "error" and "   " or (e == "warning" and "   " or "  ")
                s = s .. n .. sym
            end
            return s
        end,
        diagnostics_update_in_insert = false,
        duplicates_across_groups = true,
        enforce_regular_tabs = false,
        hover = { delay = 200, enabled = true, reveal = { "close" } },
        indicator = { style = "underline" },
        left_mouse_command = "buffer %d",
        left_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        mode = "buffers",
        modified_icon = "● ",
        move_wraps_at_ends = false,
        numbers = "none",
        offsets = {
            { filetype = "NvimTree", highlight = "Directory", separator = true, text = "File Explorer" },
            { filetype = "neo-tree", highlight = "Directory", separator = true, text = "File Explorer" },
            { filetype = "snacks_layout_box", highlight = "Directory", separator = true, text = "File Explorer" },
        },
        persist_buffer_sort = true,
        right_mouse_command = "vertical sbuffer %d",
        right_trunc_marker = "",
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_buffer_icons = true,
        show_close_icon = true,
        show_duplicate_prefix = true,
        show_tab_indicators = true,
        sort_by = "id",
        style_preset = bufferline.style_preset.default,
        tab_size = 18,
        themable = true,
        truncate_names = true,
    },
})

vim.api.nvim_create_autocmd("User", {
    pattern = "ColourschemeApplied",
    group = vim.api.nvim_create_augroup("BufferlineTransparency", { clear = true }),
    desc = "Strip bufferline backgrounds after a theme change",
    callback = function()
        for name in pairs(vim.api.nvim_get_hl(0, {})) do
            if name:match("^BufferLine") or name:match("^TabLine") then
                local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
                if hl.bg ~= nil then
                    hl.bg = nil
                    vim.api.nvim_set_hl(0, name, hl)
                end
            end
        end
    end,
})

vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev tab" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next tab" })
