return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", --both are optionals for debugging
		{ "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
	},
	lazy = false,
	keys = {
		{ "<leader>v", "<cmd>VenvSelect<cr>" },
	},
	config = function()
		require("venv-selector").setup {
			settings = {
				search = {
					my_venvs = {
						command = "fd python$ ./venv", -- Sample command, need to be changed for your own venvs
					},
				},
			},
		}
	end,
}
