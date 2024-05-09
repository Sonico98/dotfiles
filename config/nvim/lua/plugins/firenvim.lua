return {
	'glacambre/firenvim',

	-- Lazy load firenvim
	-- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
	lazy = not vim.g.started_by_firenvim,
	keys = {
		{ "<Esc><Esc>", "<Cmd>call firenvim#focus_page()<CR>" },
	},
	config = function()
		vim.g.firenvim_config = {
			globalSettings = { alt = "all" },
			localSettings = {
				[".*"] = {
					takeover = "always",
				},
				["https?://(www)?\\.?google\\.com\\.?[a-z]*"] = {
					takeover = "never",
				},
				["https?://(www)?\\.?regex101\\.com"] = {
					takeover = "never",
				},
			},
		}
	end,
	build = function()
		vim.fn["firenvim#install"](0)
	end
}
