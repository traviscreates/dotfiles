return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>vg", vim.cmd.Git)
	end,
}
