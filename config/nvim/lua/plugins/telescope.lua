return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-treesitter/nvim-treesitter" },
		{ "nvim-tree/nvim-web-devicons" },
		-- Yank history extension
		{ "gbprod/yanky.nvim" },
		-- FZF extension
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make"
		},
		-- Zoxide extension
		{
			"jvgrootveld/telescope-zoxide",
			dependencies = { "nvim-lua/popup.nvim" }
		}
	},
	cmd = { "Telescope" },
	keys = {
		{ "<C-/>", "<Cmd>Telescope current_buffer_fuzzy_find<CR>"},
		{ "<leader>tb", "<Cmd>Telescope buffers<CR>"},
		{ "<leader>tg", "<Cmd>Telescope live_grep<CR>"},
		{ "<leader>tc", "<Cmd>Telescope command_history<CR>"},
		{ "<leader>tf", "<Cmd>Telescope fd<CR>"},
		{ "<leader>ty", "<Cmd>Telescope yank_history<CR>" },
		{ "<leader>zo", "<Cmd>Telescope zoxide list<CR>"}
	},
	config = function()
		require("telescope").setup {
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						width = 0.99,
						preview_width = 0.65
					}
				}
			},
			extensions = {
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true,  -- override the generic sorter
					override_file_sorter = true,     -- override the file sorter
					case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
				}
			}
		}
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("yank_history")
		require("telescope").load_extension("zoxide")
	end
}
