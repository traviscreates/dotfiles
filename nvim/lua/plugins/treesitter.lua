-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	"nvim-treesitter/playground",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"go",
			"html",
			"javascript",
			"lua",
			"markdown",
			"python",
			"sql",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		},
		auto_install = true,
		highlight = {
			enable = true,
		},
		indent = { enable = true },
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
		require("nvim-treesitter-playground.configs").setup()
		if vim.fn.exists(":TSEnable") then
			vim.cmd("TSEnable highlight")
		end
		-- There are additional nvim-treesitter modules that you can use to interact
		-- with nvim-treesitter. You should go explore a few and see what interests you:
		--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
		--    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
		--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
	end,
}
