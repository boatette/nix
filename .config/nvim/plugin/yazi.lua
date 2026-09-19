vim.pack.add({ "https://github.com/mikavilpas/yazi.nvim" })

require("yazi").setup({
    open_for_directories = true,
    open_multiple_tabs = true,

    keymaps = { replace_in_directory = false },

    integrations = {
        grep_in_directory = "snacks.picker",
        grep_in_selected_files = "snacks.picker",
        bufdelete_implementation = "snacks-if-available",
        picker_add_copy_relative_path_action = "snacks.picker",
    },

    hooks = {
        yazi_opened = function(_, buffer, _)
            vim.keymap.set("t", "<Esc><Esc>", "<Esc><Esc>", { buffer = buffer })
            vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = buffer, nowait = true })

            for _, key in ipairs({ "<Esc>", "q" }) do
                vim.keymap.set("n", key, "<cmd>startinsert<cr>", { buffer = buffer, nowait = true })
            end
        end,
    },
})

vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "File explorer" })
vim.keymap.set("n", "<leader>E", "<cmd>Yazi cwd<cr>", { desc = "File explorer (cwd)" })
