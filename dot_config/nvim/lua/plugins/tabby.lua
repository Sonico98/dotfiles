return {
	"nanozuki/tabby.nvim",
	dependencies = {
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
	init = function()
		local map = vim.api.nvim_set_keymap
		local opts = { noremap = true, silent = true }
		map("n", "H", "<Cmd>:tabp<CR>", opts)
		map("n", "L", "<Cmd>:tabn<CR>", opts)
		map("n", "<leader>bc", "<Cmd>:tabclose<CR>", opts)
		map("n", "<leader>ba", "<Cmd>:$tabnew<CR>", opts)
		map("n", "<leader>bn", "<Cmd>:bnext<CR>", opts)
		map("n", "<leader>bp", "<Cmd>:bprev<CR>", opts)
	end,
	config = function()
		local theme = {
			fill = 'TabLineFill',
			head = 'TabLine',
			current_tab = 'CommandMode',
			tab = 'TabLine',
			win = 'TabLine',
			tail = 'TabLine',
		}
		nerdfont = true
		lualine_theme = ayu
		require('tabby').setup({
			line = function(line)
				return {
					{
						line.sep('/', theme.head, theme.fill),
					},
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.current_tab or theme.tab

						-- remove count of wins in tab with [n+] included in tab.name()
						local name = tab.name()
						local index = string.find(name, "%[%d")
						local tab_name = index and string.sub(name, 1, index - 1) or name


						-- indicate if any of buffers in tab have unsaved changes
						local modified = false
						local win_ids = require('tabby.module.api').get_tab_wins(tab.id)
						for _, win_id in ipairs(win_ids) do
							if pcall(vim.api.nvim_win_get_buf, win_id) then
								local bufid = vim.api.nvim_win_get_buf(win_id)
								if vim.api.nvim_buf_get_option(bufid, "modified") then
									modified = true
									break
								end
							end
						end

						return {
							line.sep('/', hl, theme.fill),
							tab.number(),
							tab_name,
							modified and '',
							tab.close_btn(''),
							line.sep('/', hl, theme.fill),
							hl = hl,
							margin = ' ',
						}
					end),
					line.spacer(),
					{
						line.sep('/', theme.tail, theme.fill),
						{ '  ', hl = theme.tail },
					},
					hl = theme.fill,
				}
			end,
		})
	end
}
