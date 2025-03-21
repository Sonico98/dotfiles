return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		{ "kevinhwang91/promise-async" },
		{
			"luukvbaal/statuscol.nvim",
			config = function()
				local builtin = require("statuscol.builtin")
				require("statuscol").setup({
					foldfunc = "builtin",
					setopt = true,
					relculright = true,
					segments = {
						{ text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
						{ text = { "%s" }, maxwidth = 2, auto = true, click = "v:lua.ScSa" },
						{ text = { builtin.lnumfunc }, click = "v:lua.ScLa", },
						{ text = { "  " }, }
					},
					clickhandlers = {       -- builtin click handlers
						Lnum                   = builtin.lnum_click,
						FoldClose              = builtin.foldclose_click,
						FoldOpen               = builtin.foldopen_click,
						FoldOther              = builtin.foldother_click,
						DapBreakpointRejected  = builtin.toggle_breakpoint,
						DapBreakpoint          = builtin.toggle_breakpoint,
						DapBreakpointCondition = builtin.toggle_breakpoint,
						DiagnosticSignError    = builtin.diagnostic_click,
						DiagnosticSignHint     = builtin.diagnostic_click,
						DiagnosticSignInfo     = builtin.diagnostic_click,
						DiagnosticSignWarn     = builtin.diagnostic_click,
						GitSignsTopdelete      = builtin.gitsigns_click,
						GitSignsUntracked      = builtin.gitsigns_click,
						GitSignsAdd            = builtin.gitsigns_click,
						GitSignsChange         = builtin.gitsigns_click,
						GitSignsChangedelete   = builtin.gitsigns_click,
						GitSignsDelete         = builtin.gitsigns_click,
					}
				})
			end
		}
	},
	init = function ()
		vim.o.foldlevel = 99 -- Using ufo provider needs a large value
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
		vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
		vim.o.foldcolumn = '1' -- '0' is not bad
		vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
		vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
	end,
	config = function ()
		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				return {'treesitter', 'indent'}
			end
		})
	end
}
