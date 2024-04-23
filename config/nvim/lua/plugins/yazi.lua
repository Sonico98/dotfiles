return {
	"mikavilpas/yazi.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	event = "VeryLazy",
	keys = {
		{
			"<C-n>", function() require("yazi").yazi() end, { desc = "Open the file manager" },
		},
	},
	opts = {
		open_for_directories = true,
	},
}
