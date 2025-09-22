return {
	"catppuccin/nvim",
	priority = 1000,
	init = function()
		vim.o.termguicolors = true
	end,
	config = function()
		require("catppuccin").setup({
			flavour = "auto",
			background = {
				light = "latte",
				dark = "mocha",
			},
			transparent_background = true,
			float = {
				transparent = true,
				solid = true,
			},
			no_underline = true,
			styles = {
				comments = { "italic" },
				conditionals = { "italic" },
				loops = { "italic" },
			},
			default_integrations = true,
			auto_integrations = true,
		})
		vim.cmd.colorscheme("catppuccin")
	end
}
