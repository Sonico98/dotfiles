-- Better color highlighting
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufRead", "FileReadPost", "StdinReadPost", "BufWritePost" },
	config = function()
		require('nvim-treesitter.configs').setup {
			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			highlight = {
				-- `false` will disable the whole extension
				enable = true,
				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				additional_vim_regex_highlighting = false,
				disable = function(lang, buf)
					local max_filesize = 800 * 1024 -- 800 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},

			indent = {
				enable = true
			},

			rainbow = {
				enable = true,
			}
		}
	end
}
