local opt = vim.opt
local o = vim.o

o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.termguicolors = true
o.laststatus = 3

o.cursorline = true
o.colorcolumn = "120"
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false

o.splitright = true
o.splitbelow = true

o.winborder = "single"

vim.schedule(function()
    opt.clipboard = "unnamedplus"
end)

o.updatetime = 50
o.timeoutlen = 500

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true
o.autoindent = true
o.breakindent = true

o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

opt.completeopt = { "menu", "menuone", "noinsert" }
o.pumheight = 10
o.pumblend = 0

o.undofile = true
o.swapfile = false
o.backup = false
o.writebackup = false
o.confirm = true
o.autoread = true

o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

opt.list = true
opt.listchars = { tab = "→ ", trail = "·", extends = "⟩", precedes = "⟨" }
opt.fillchars = {
    foldopen = "▾",
    foldclose = "▸",
    eob = " ",
}

o.mouse = "a"

if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep --smart-case --hidden"
    opt.grepformat = "%f:%l:%c:%m"
end

opt.whichwrap:append("<>[]hl")
