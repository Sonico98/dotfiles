return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<C-/>", "<Cmd>FzfLua blines<CR>" },
		{ "<leader>bf", "<Cmd>FzfLua buffers<CR>" },
		{ "<leader>gr",  "<Cmd>FzfLua live_grep<CR>" },
		{ "<leader>c", "<Cmd>FzfLua command_history<CR>" },
		{ "<leader>f", "<Cmd>FzfLua files<CR>" },
	},
	config = function()
		require("fzf-lua").setup({})
	end
}
