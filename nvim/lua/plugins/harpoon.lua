return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	requires = { "nvim-lua/plenary.nvim" },
	settings = {
		save_on_toggle = true,
		sync_on_ui_close = true,
		key = function()
			return vim.loop.cwd()
		end,
	},
	config = function()
		local harpoon = require("harpoon")

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "[A]dd to harpoon menu" })

		vim.keymap.set("n", "<leader>h", function()
			harpoon.ui:toggle_quick_menu(harpoon:list(), {
				title = "",
				title_pos = "center",
				border = "rounded",
			})
		end, { desc = "Toggle [H]arpoon menu" })

		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end, { desc = "Goto harpoon [1]" })

		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end, { desc = "Goto harpoon [2]" })

		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end, { desc = "Goto harpoon [3]" })

		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end, { desc = "Goto harpoon [4]" })

		vim.keymap.set("n", "<leader>5", function()
			harpoon:list():select(5)
		end, { desc = "Goto harpoon [5]" })

		vim.keymap.set("n", "<leader>6", function()
			harpoon:list():select(6)
		end, { desc = "Goto harpoon [6]" })

		vim.keymap.set("n", "<leader>7", function()
			harpoon:list():select(7)
		end, { desc = "Goto harpoon [7]" })

		vim.keymap.set("n", "<leader>8", function()
			harpoon:list():select(8)
		end, { desc = "Goto harpoon [8]" })

		vim.keymap.set("n", "<leader>9", function()
			harpoon:list():select(9)
		end, { desc = "Goto harpoon [9]" })

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<leader>-", function()
			harpoon:list():prev()
		end, { desc = "Goto harpoon previous buffer" })

		vim.keymap.set("n", "<leader>+", function()
			harpoon:list():next()
		end, { desc = "Goto harpoon next buffer" })
	end,
}
