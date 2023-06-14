return {
	"asiryk/auto-hlsearch.nvim",
	event = "VeryLazy",
	config = function()
		require("auto-hlsearch").setup()
	end
}
