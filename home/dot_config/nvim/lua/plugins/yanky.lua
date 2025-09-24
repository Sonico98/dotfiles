return {
	"gbprod/yanky.nvim",
	event = "VeryLazy",
	keys = {
		{ "p",  "<Plug>(YankyPutAfter)" },
		{ "P",  "<Plug>(YankyPutBefore)" },
		{ "gp",  "<Plug>(YankyGPutBefore)" },
		{ "gP", "<Plug>(YankyGPutBefore)" },
		{ "<C-o>", "<Plug>(YankyCycleForward)" },
		{ "<C-i>", "<Plug>(YankyCycleBackward)" },
	},
	config = function()
		require("yanky").setup({
			ring = {
				history_length = 100,
				storage = "memory",
				sync_with_numbered_registers = true,
				cancel_event = "update",
			},
			picker = {
				select = {
					action = nil, -- nil to use default put action
				},
				telescope = {
					mappings = nil, -- nil to use default mappings
				},
			},
			system_clipboard = {
				sync_with_ring = true,
			},
			highlight = {
				on_put = true,
				on_yank = false,
				timer = 500,
			},
			preserve_cursor_position = {
				enabled = true,
			},
		})
	end
}
