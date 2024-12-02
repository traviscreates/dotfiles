local console = require("console")

-- [[ Basic Keymaps ]]

-- vim.keymap.set("n", "<leader>p", ":lua require('console').insertConsoleLog()<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set(
	"n",
	"<leader>e",
	":lua vim.diagnostic.open_float()<CR>:lua vim.diagnostic.open_float()<CR>",
	{ desc = "Show diagnostic [E]rror messages" }
)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", "<C-M-Left>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-M-Down>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-M-Up>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-M-Right>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>n", vim.cmd.Ex, { desc = "[N]etrw file tree" })

vim.keymap.set("i", "<C-Del>", "X<Esc>ce")
vim.keymap.set("n", "<C-Del>", "<Esc>ce")
vim.keymap.set("i", "<C-H>", "<C-W>")
vim.keymap.set("n", "<C-H>", "db")

vim.keymap.set("n", "S", ":%s//g<Left><Left>")
vim.keymap.set("n", "<leader>'", ":s/'/\"/g<CR>")
vim.keymap.set("v", "<leader>'", ":s/'/\"/g<CR>")

vim.keymap.set("n", "<leader>mo", function()
	vim.lsp.start({
		name = "mojo",
		cmd = { "mojo-lsp-server" },
		root_dir = require("lspconfig").util.find_git_ancestor(),
	})
end, { desc = "Launch Mojo LSP" })
