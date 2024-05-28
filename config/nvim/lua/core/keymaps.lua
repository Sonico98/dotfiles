-- Shorten function name
local map = vim.keymap.set

-- Use ; instead of : for commands
map('n', ';', ':')
map('n', ':', ';')
map('v', ';', ':')

-- Access system clipboard with Ctrl + y/p
map('n', '<C-y>', '"+y')
map('v', '<C-y>', '"+y')
-- Paste and autoindent
map('n', '<C-p>', '"+p`[v`]=')

-- Toggle auto-indenting for code paste
map('n', '<F2>', ':set invpaste paste?<CR>')

-- Move tabs
map('n', '<S-Left>', '<Cmd>tabmove-<CR>')
map('n', '<S-Right>', '<Cmd>tabmove+<CR>')

-- Delete a whole word backwards
map('n', 'db', 'dvb')
map('n', 'dvb', 'db')

-- Move cursor in insert mode without arrow keys
map('i', '<C-j>', '<Left>')
map('i', '<C-k>', '<Right>')

-- Quickly move between buffers
map('n', '<leader>bn', '<Cmd>bnext<CR>')
map('n', '<leader>bp', '<Cmd>bprev<CR>')

-- Exit from terminal mode
map('t', '<ESC><ESC>', '<C-\\><C-n>')
------------------------
-- Deprecated keymaps --
------------------------
-- Automatically close character pairs
-- Replaced with coc-pairs
-- map('i', '"', '""<left>')
-- map('i', '\'', '\'\'<left>')
-- map('i', '(', '()<left>')
-- map('i', '[', '[]<left>')
-- map('i', '{', '{}<left>')
-- map('i', '{<CR>', '{<CR>}<ESC>O')
-- map('i', '{;<CR>', '{<CR>};<ESC>O')
