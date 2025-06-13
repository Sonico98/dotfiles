return {
	"Luxed/ayu-vim",
	priority = 1000,
	init = function()
		vim.o.termguicolors = true
		vim.g.ayucolor = "dark"
		vim.g.ayu_italic_comment = 1
		vim.g.ayu_extended_palette = 1
		-- Set theme overrides
		local function custom_ayu_colors()

			-- Add two extra lines to ~/.local/share/nvim/lazy/ayu-vim/autoload/ayu.vim
			-- One under if s:extended_palette
			-- let g:ayu#palette['extended_comment']   = {'light': '#adafb2', 'mirage': '#6e7c8e', 'dark': '#858585'}
			-- The second after the following else
			-- let g:ayu#palette['extended_comment']   = g:ayu#palette['syntax_comment']

			local overrides = {
				{ "Normal", "", "" },
				{ "SignColumn", "", "" },
				{ "LineNr", "ui_fg", "" },
				{ "CursorLine", "", "editor_line" },
				{ "CursorLineNR", "common_accent", "editor_line" },
				{ "Comment", "extended_comment", "", vim.g.ayu_italic_comment and 'italic' or '' },
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
