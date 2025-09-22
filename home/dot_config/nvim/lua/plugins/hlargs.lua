return {
	"m-demare/hlargs.nvim",
	event = { "BufRead", "FileReadPost", "StdinReadPost", "BufWritePost" },
	config = function()
		require("hlargs").setup {
			color = "#35D27F",
			use_colorpalette = true,
			colorpalette = {
				{ fg = "#35D27F" },
				{ fg = "#EB75D6" },
				{ fg = "#59B8F5" },
				{ fg = "#7FEC35" },
				{ fg = "#F6B223" },
				{ fg = "#F67C1B" },
				{ fg = "#CF447F" },
				{ fg = "#5FD6FE" },
				{ fg = "#3FF65E" },
				{ fg = "#6F068E" },
			},
			-- Use contextual semantic highlighting if available
			disable = function(_, bufnr)
				if vim.b.semantic_tokens then
					return true
				end
				local clients = vim.lsp.get_active_clients { bufnr = bufnr }
				for _, c in pairs(clients) do
					local caps = c.server_capabilities
					if c.name ~= "null-ls" and caps.semanticTokensProvider and caps.semanticTokensProvider.full then
						vim.b.semantic_tokens = true
						return vim.b.semantic_tokens
					end
				end
			end
		}
	end
}
