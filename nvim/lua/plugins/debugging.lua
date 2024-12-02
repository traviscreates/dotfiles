return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"leoluz/nvim-dap-go",
		"mfussenegger/nvim-dap-python",
		-- "mfussenegger/nvim-dap-cpptools",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("dapui").setup()
		require("dap-go").setup()

		--[[ Python ]]

		local python_executable_path = vim.fn.exepath("python")
		require("dap-python").setup(python_executable_path)
		-- require("core.utils").load_mappings("dap_python")

		dap.set_log_level("DEBUG")
		dap.configurations.python = {
			-- 	{
			-- 		type = "python",
			-- 		request = "launch",
			-- 		name = "Debug BFM train.py",
			-- 		program = "${vim.env.PYTHONPATH}/scripts/predict.py",
			-- 		args = { "${vim.env.PYTHONPATH}/sap_bfm/cfg/soac_debug.yaml" },
			-- 		console = "integratedTerminal",
			-- 	},
			{
				type = "python",
				request = "launch",
				name = "Launch Current File",
				program = "${file}",
				cwd = vim.fn.getcwd(),
				justMyCode = false,
				env = {
					PYTHONPATH = vim.fn.getcwd(),
				},
			},
			{
				type = "python",
				request = "launch",
				name = "Debug BFM Batch Inference Unit Test",
				program = "${workspaceFolder}/tests/unit/bfm_batch_inference/test_bfm_batch_inference.py",
				args = { "-m", "unittest", "-v" },
				console = "integratedTerminal",
				cwd = vim.fn.getcwd(),
				justMyCode = false,
				env = {
					PYTHONPATH = vim.fn.getcwd(),
				},
			},
		}

		--[[ C++ ]]

		dap.adapters.lldb = {
			type = "executable",
			command = "/opt/homebrew/opt/llvm/bin/lldb-dap",
			name = "lldb",
		}

		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "lldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/parser_test")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
				-- If you get a "process exited with status -1 (error 193)" error, enable these options
				runInTerminal = false,
				externalConsole = false,
				-- If `lldb` is not in your PATH, uncomment the following line and provide the correct path.
				miDebuggerPath = "/opt/homebrew/opt/llvm/bin/lldb-dap",
			},
		}

		--[[
		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = os.getenv("HOME")
				.. "/.local/share/nvim/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
			options = {
				initialize_timeout_sec = 10,
			},
		}

		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/lexer_test")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				setupCommands = {
					{
						text = "-enable-pretty-printing",
						description = "Enable pretty-printing for gdb",
						ignoreFailures = false,
					},
				},
				MIMode = "lldb",
				miDebuggerPath = "/opt/homebrew/opt/llvm/bin/lldb-dap",
				logging = { engineLogging = false },
			},
		}
		--]]

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<leader>dc", dap.continue, {})
		vim.keymap.set("n", "<F10>", dap.step_over, {})
		vim.keymap.set("n", "<F11>", dap.step_into, {})
		vim.keymap.set("n", "<F12>", dap.step_out, {})
		vim.keymap.set("n", "<leader>dl", dap.run_last, {})
	end,
}
