return {
	'0x00-ketsu/markdown-preview.nvim',
	ft = { 'md', 'markdown', 'mkd', 'mkdn', 'mdwn', 'mdown', 'mdtxt', 'mdtext', 'rmd', 'wiki' },
	config = function()
		require('markdown-preview').setup { 
			term = {
				-- reload term when rendered markdown file changed
				reload = {
					enable = true,
					events = {'InsertLeave', 'TextChanged', 'CursorMovedI'},
				}
			}
		}
	end
}
