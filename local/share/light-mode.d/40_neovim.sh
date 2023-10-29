#!/bin/bash

sed -i -e 's#vim.o.background = "dark"#vim.o.background = "light"#' \
	-e 's#vim.g.ayucolor = "dark"#vim.g.ayucolor = "light"#' \
	~/.config/nvim/lua/plugins/ayu-vim.lua
