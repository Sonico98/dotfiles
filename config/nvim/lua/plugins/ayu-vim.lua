return {
	"Luxed/ayu-vim",
	priority = 1000,
	init = function()
		vim.o.termguicolors = true
		vim.o.background = "dark"
		vim.g.ayucolor = "dark"
		vim.g.ayu_italic_comment = 1
		vim.g.ayu_extended_palette = 1
	end,
	config = function()
		-- Set theme overrides
		local function custom_ayu_colors()
			local overrides = {
				{ "Normal", "", "" },
				{ "SignColumn", "", "" },
				{ "LineNr", "ui_fg", "" },
				{ "CursorLine", "", "editor_line" },
				{ "CursorLineNR", "common_accent", "editor_line" },
			}

			for _, colors in ipairs(overrides) do
				vim.api.nvim_call_function("ayu#hi", colors)
			end
		end

		-- Apply the theme overrides
		local custom_colors = vim.api.nvim_create_augroup("custom_colors", {})
		vim.api.nvim_create_autocmd(
			{ "ColorScheme" },
			{
				pattern = "ayu",
				callback = custom_ayu_colors,
				group = custom_colors
			}
		)	-- Apply the colorscheme
		vim.cmd( [[colorscheme ayu]] )
	end
}
