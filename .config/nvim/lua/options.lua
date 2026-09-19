local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.laststatus = 3
opt.cmdheight = 1

opt.cursorline = true
opt.cursorlineopt = "line"
opt.colorcolumn = "120"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

opt.splitright = true
opt.splitbelow = true
opt.winborder = "single"

opt.updatetime = 250
opt.timeoutlen = 500

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

opt.completeopt = { "menu", "menuone", "noinsert" }
opt.pumheight = 10
opt.pumblend = 0

opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.confirm = true
opt.autoread = true
opt.hidden = true

opt.foldenable = true
opt.foldlevel = 99
opt.foldlevelstart = 99

opt.list = true
opt.listchars = { tab = "→ ", trail = "·", extends = "⟩", precedes = "⟨" }
opt.fillchars = { foldopen = "▾", foldclose = "▸", eob = " " }

opt.mouse = "a"
opt.mousemoveevent = true
opt.whichwrap = "b,s,<,>,[,],h,l"

opt.encoding = "utf-8"
opt.errorbells = false
opt.visualbell = false

opt.grepprg = vim.fn.executable("rg") == 1 and "rg --vimgrep --smart-case --hidden" or vim.o.grepprg
opt.grepformat = vim.fn.executable("rg") == 1 and "%f:%l:%c:%m" or vim.o.grepformat

vim.schedule(function()
    opt.clipboard = "unnamedplus"
end)
