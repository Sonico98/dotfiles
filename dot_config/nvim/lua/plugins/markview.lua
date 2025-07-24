return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons"
	},
	config = function ()
		require("markview").setup({
			-- to what you need

			experimental = {
				check_rtp_message = false
			},
			preview = {
				modes = { "n", "no", "c", "i" }, -- Change these modes
				hybrid_modes = { "i" },     -- Uses this feature on
				callbacks = {
					on_enable = function (_, win)
						vim.wo[win].conceallevel = 2;
						vim.wo[win].concealcursor = "c";
					end
				}
			}
		})
	end
}
