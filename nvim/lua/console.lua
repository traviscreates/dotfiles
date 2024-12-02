local M = {}

function M.insertConsoleLog()
	vim.cmd("normal! o")
	vim.api.nvim_put({ "console.log(``);" }, "", true, true)
	vim.cmd("normal! ==")
	vim.cmd("normal! 2h")
	vim.cmd("startinsert")
end

return M
