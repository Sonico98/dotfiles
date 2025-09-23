return {
	"https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
	event = { "BufRead", "FileReadPost", "StdinReadPost", "BufWritePost" },
	init = function()
		vim.g.rainbow_delimiters = {
			highlight = {
				'RainbowDelimiterRed',
				'RainbowDelimiterViolet',
				'RainbowDelimiterYellow',
				'RainbowDelimiterBlue',
				'RainbowDelimiterGreen',
				'RainbowDelimiterOrange',
				'RainbowDelimiterCyan',
			},
		}
	end
}
