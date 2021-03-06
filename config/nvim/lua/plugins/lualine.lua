-- Cool statusline
return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons"
	},
	opts = {
		options = {
			theme = "ayu",
		},
		sections = {
			lualine_c = {
				{
					'filename',
					file_status = true,
					path = 3,
					shorting_target = 40,
					symbols = {
						modified = '[+]',
						readonly = '[-]',
						unnamed = '[No Name]',
					}
				}
			},
			lualine_b = {
				'branch',
				'diff',
				{
					'diagnostics',
					sources = { 'coc', 'nvim_lsp' },
					sections = { 'error', 'warn', 'info', 'hint' },
					diagnostics_color = {
						error = 'DiagnosticError',
						warn  = 'DiagnosticWarn',
						info  = 'DiagnosticInfo',
						hint  = 'DiagnosticHint',
					},
					symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' },
					colored = true,
					update_in_insert = false,
					always_visible = false,
				}
			}
		},
		extensions = { 'neo-tree', 'fugitive' }
	}
}
