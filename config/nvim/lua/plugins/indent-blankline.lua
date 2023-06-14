-- Add indentation guides to all lines
return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufRead", "FileReadPost", "StdinReadPost", "BufWritePost" },
	config = function()
		vim.opt.list = true
		require("indent_blankline").setup {
			show_end_of_line = false,
			show_current_context = true
		}
	end
}
