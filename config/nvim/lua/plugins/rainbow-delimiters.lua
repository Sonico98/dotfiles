return {
	"https://gitlab.com/HiPhish/rainbow-delimiters.nvim",
	enabled = true,
	init = function()
		vim.g.rainbow_delimiters = {
			highlight = {
				'RainbowDelimiter1',
				'RainbowDelimiter2',
				'RainbowDelimiter3',
				'RainbowDelimiter4',
			},
		}
	end
}
