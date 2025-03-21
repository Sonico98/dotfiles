-- Save files as root
return {
	"lambdalisue/suda.vim",
	cmd = { "SudaWrite", "SudaRead", "SW", "SR" },
	config = function()
		-- Alias SudaWrite to SW
		vim.cmd 'command! SW SudaWrite'
		-- Alias SudaRead to SR
		vim.cmd 'command! SR SudaRead'
	end
}
