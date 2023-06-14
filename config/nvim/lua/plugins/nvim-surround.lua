-- Easily surround text between characters
return {
	"kylechui/nvim-surround",
	dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	event = { "BufRead", "FileReadPost", "StdinReadPost", "BufWritePost" },
	priority = 5,
	config = function()
		require("nvim-surround").setup({
			keymaps = {
				insert = "<C-g>s",
				insert_line = "<C-g>S",
				normal = "s",
				normal_cur = "ss",
				normal_line = "yS",
				normal_cur_line = "ySS",
				visual = "s",
				visual_line = "gS",
				delete = "ds",
				change = "cs",
			},
		})
	end
}
