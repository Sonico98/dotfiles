#!/bin/bash

sed -i -e 's#vim.o.background = "light"#vim.o.background = "dark"#' \
	-e 's#vim.g.ayucolor = "light"#vim.g.ayucolor = "dark"#' \
	~/.config/nvim/lua/plugins/ayu-vim.lua
