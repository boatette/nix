local map = vim.keymap.set

local FLAKE = "~/nix#redux"

local function rebuild(mode, sudo)
    return function()
        require("snacks").terminal(
            ("%snixos-rebuild %s --flake %s"):format(sudo and "sudo " or "", mode, FLAKE),
            { interactive = true }
        )
    end
end

map("n", "<leader>ns", rebuild("switch", true), { desc = "Rebuild switch" })
map("n", "<leader>nt", rebuild("test", true), { desc = "Rebuild test" })
map("n", "<leader>nb", rebuild("boot", true), { desc = "Rebuild boot" })
map("n", "<leader>nd", rebuild("dry-build", false), { desc = "Rebuild dry-build" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>v", "ggVG", { desc = "Select whole buffer" })
map("v", "p", '"_dP`[v`]=', { desc = "Paste without yank" })
map("n", "J", "mzJ`z", { desc = "Better join" })
map("n", "<leader>R", function()
    local session = vim.fn.stdpath("state") .. "/restart_session.vim"
    vim.cmd("mksession! " .. vim.fn.fnameescape(session))
    vim.cmd("restart source " .. vim.fn.fnameescape(session))
end, { desc = "Restart Neovim" })

map("n", "i", function()
    return vim.fn.getline("."):len() == 0 and '"_cc' or "i"
end, { expr = true, desc = "Auto-indent on empty line" })

map("n", "j", "gj", { desc = "Navigate wrapped lines" })
map("n", "k", "gk", { desc = "Navigate wrapped lines" })

map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

map("v", "J", ":m '>+1<cr>gv=gv", { silent = true, desc = "Move lines down" })
map("v", "K", ":m '<-2<cr>gv=gv", { silent = true, desc = "Move lines up" })

map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centred)" })
map("n", "n", "nzzzv", { desc = "Next search result (centred)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centred)" })

map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })

map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
map("n", "<leader>w-", "<C-W>s", { desc = "Split below" })
map("n", "<leader>w|", "<C-W>v", { desc = "Split right" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalise windows" })

map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>co", function()
    vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
    })
end, { desc = "Organise imports" })
map("n", "<leader>cq", function()
    vim.lsp.buf.code_action({
        context = { only = { "quickfix" }, diagnostics = {} },
        apply = true,
    })
end, { desc = "Quick fix" })
map("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run code lens" })
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Prev quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "next quickfix" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
