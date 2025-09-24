return {
	"andre-kotake/nvim-chezmoi",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope.nvim" },
	},
	opts = {
		edit = {
			apply_on_save = "auto",
		},
	},
	config = function(_, opts)
		require("nvim-chezmoi").setup(opts)
	end,
}
