-- Alias SW to SudaWrite
vim.cmd 'command! SW SudaWrite'

-- Restore last position in file
vim.api.nvim_create_autocmd(
	"BufReadPost" ,
	{ command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]] }
)
