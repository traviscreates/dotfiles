-- [[ Basic Settings ]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus" -- Sync clipboard between os and nivm
vim.opt.showmode = false -- no show because it's in the status line

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.breakindent = true
vim.opt.wrap = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.formatoptions:remove("c")
vim.opt.fixeol = false

vim.api.nvim_create_augroup("CppIndentation", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "CppIndentation",
	pattern = { "cpp", "c++", "h", "hpp" },
	callback = function()
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
		vim.bo.softtabstop = 4
	end,
})

vim.api.nvim_create_augroup("PythonIndentation", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "PythonIndentation",
	pattern = "python",
	callback = function()
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
	end,
})

vim.opt.foldmethod = "manual"
vim.opt.foldexpr = "nvim_treesitter#foldexpr(),manual"

vim.g.netrw_bufsettings = "noma nomod nonu nobl nowrap ro rnu"

vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.isfname:append("@-@")

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.inccommand = "split"
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.ruler = true
-- Using NeoColumn instead
-- vim.opt.colorcolumn = "80"
vim.opt.scrolloff = 8

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300
vim.opt.ttyfast = true

vim.opt.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.syntax = "enable"
vim.opt.termguicolors = true
vim.opt.guifont = "Hack Nerd Font Mono:h12"

vim.filetype.add({
	extension = {
		mojo = "mojo",
	},
})
