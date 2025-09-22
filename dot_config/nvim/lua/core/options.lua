--Show the characters being typed
vim.o.showcmd = true

--Change vim title to be just [filename - VIM]
vim.o.titlestring = [[%t - VIM]]
vim.o.title = true

-- Show line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Highlight the current line
vim.o.cursorline = true

-- Enable the mouse and detect mouse movement
vim.o.mouse = "a"
vim.o.mousemoveevent = true

-- Remember undo between sessions
vim.o.undofile = true

-- Set tab indent size
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- Wrap on word boundary
vim.o.linebreak = true

-- Faster scrolling
vim.o.lazyredraw = true

-- Scroll when near the top or bottom
vim.o.scrolloff = 10

-- Disable some builtin plugins
local disabled_built_ins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"bugreport",
	"tutor"
}

-- Allow copying to clipboard over SSH
local function paste()
  return {
    vim.split(vim.fn.getreg(''), '\n'),
    vim.fn.getregtype(''),
  }
end

if vim.env.SSH_TTY then
	vim.g.clipboard = {
		name = 'OSC 52',
		copy = {
			['+'] = require('vim.ui.clipboard.osc52').copy('+'),
			['*'] = require('vim.ui.clipboard.osc52').copy('*'),
		},
		paste = {
			['+'] = paste,
			['*'] = paste,
		},
	}
end
