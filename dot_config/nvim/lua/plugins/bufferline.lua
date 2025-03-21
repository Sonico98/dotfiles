-- Better looking tabs
return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "BufCreate",
	config = function()
		require("bufferline").setup {
			options = {
				mode = "tabs",
				always_show_bufferline = false,
				diagnostics = "coc",
				offsets = {
					{
						filetype = "neo-tree",
						text = "File Explorer",
						highlight = "Directory",
						separator = true
					}
				},
				hover = {
					enabled = true,
					delay = 0,
					reveal = { 'close' }
				}
			}
		}
		vim.keymap.set("n", "H", "<Cmd>BufferLineCyclePrev<CR>")
		vim.keymap.set("n", "L", "<Cmd>BufferLineCycleNext<CR>")
	end
}
