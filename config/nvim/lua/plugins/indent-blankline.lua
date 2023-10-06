-- Add indentation guides to all lines
return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufRead", "FileReadPost", "StdinReadPost", "BufWritePost" },
	main = "ibl",
	opts = {},
	config = function()
		require("ibl").setup {
			scope = { show_start = false, show_end = false },
			indent = { char = { '▎', '|', '¦', '┆', '┊' , '⋮' } }
		}
	end
}
