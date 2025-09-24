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

-- Open yazi.nvim on directories
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 1 then
            local arg = tostring(vim.fn.argv(0))
            if vim.fn.isdirectory(arg) == 1 then
                vim.api.nvim_buf_delete(0, {})
                require('yazi').yazi({}, arg)
            end
        end
    end,
})

-- Auto-create parent directories (except for URIs "://").
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
  callback = function(args)
    local filepath = vim.fn.expand(args.file)
    -- Skip if it's a URI (e.g., netrw, remote files)
    if not filepath:match("://") then
      local dir = vim.fn.fnamemodify(filepath, ":p:h")
      if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
      end
    end
  end,
})

