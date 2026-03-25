-- Easily surround text between characters
return {
	"kylechui/nvim-surround",
	dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	event = "VeryLazy",
	priority = 5,
	-- :h nvim-surround.keymaps
	keys = {
		{ "<C-g>s", "<Plug>(nvim-surround-insert)", mode = {"i"} },
		{ "<C-g>S", "<Plug>(nvim-surround-insert-line)", mode = {"i"} },
		{ "s", "<Plug>(nvim-surround-normal)", mode = {"n"} },
		{ "ss", "<Plug>(nvim-surround-normal-cur)", mode = {"n"} },
		{ "yS", "<Plug>(nvim-surround-normal-line)", mode = {"n"} },
		{ "ySS", "<Plug>(nvim-surround-normal-cur-line)", mode = {"n"} },
		{ "s", "<Plug>(nvim-surround-visual)", mode = {"x"} },
		{ "gS", "<Plug>(nvim-surround-visual-line)", mode = {"x"} },
		{ "ds", "<Plug>(nvim-surround-delete)", mode = {"n"} },
		{ "cs", "<Plug>(nvim-surround-change)", mode = {"n"} },
		{ "cS", "<Plug>(nvim-surround-change-line)", mode = {"n"} },
	}
}
