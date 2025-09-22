return {
	"OmniSharp/omnisharp-vim",
	enabled = false,
	ft = { "cs" },
	dependencies = {
		{ "dense-analysis/ale",
		config = function ()
			vim.g.ale_linters_explicit = 1
			vim.g.ale_linters = { cs = { "omnisharp" } }
			vim.g.ale_virtualtext_cursor = "disabled"
			vim.g.ale_disable_lsp = 1
			vim.g.ale_completion_autoimport = 0
		end
		}
	},
	config = function()
		vim.g.Omnisharp_server_path = "/usr/bin/omnisharp"
		vim.g.Omnisharp_server_use_net6 = 1
	end
}
