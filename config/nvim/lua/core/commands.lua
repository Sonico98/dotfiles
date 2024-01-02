-- Alias SW to SudaWrite
vim.cmd 'command! SW SudaWrite'

-- Restore last position in file
vim.api.nvim_create_autocmd(
	"BufReadPost" ,
	{ command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]] }
)

-- Copy all text that match a search
vim.cmd([[
	function! CopyMatches(reg)
	let hits = []
	%s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
	  let reg = empty(a:reg) ? '+' : a:reg
	  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
	endfunction
	command! -register CopyMatches call CopyMatches(<q-reg>)
]])
