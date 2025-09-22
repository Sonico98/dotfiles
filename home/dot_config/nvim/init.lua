-- Change leader to the spacebar
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Source everything else
require("core/lazy")
require("core/options")
require("core/commands")
require("core/keymaps")
