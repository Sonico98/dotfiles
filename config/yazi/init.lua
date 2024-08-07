-- Full borders
require("full-border"):setup()

-- Show symlink pointers at the bottom
function Status:name()
	local h = cx.active.current.hovered
	if h == nil then
		return ui.Span("")
	end

	local linked = ""
	if h.link_to ~= nil then
		linked = " -> " .. tostring(h.link_to)
	end
	return ui.Span(" " .. h.name .. linked)
end

-- Make icon colors follow the filename's color
function Entity:icon()
  local icon = self._file:icon()
  return ui.Line(icon and " " .. icon.text .. " " or "")
end

-- Show relative numbers
require("relative-motions"):setup({ show_numbers="relative", show_motion = true })

-- Add browsed directories to zoxide's db
require("zoxide"):setup {
    update_db = true,
}

-- Sync yanked files across yazi instances
require("session"):setup {
	sync_yanked = true,
}

-- Render theme colors on the right pane
require("mime-preview"):setup()

require("yatline"):setup({
	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = "" },
	inverse_separator = { open = "", close = "" },

	style_a = {
		fg = "black",
		bg_mode = {
			normal = "blue",
			select = "green",
			un_set = "red"
		}
	},
	style_b = { bg = "#001023", fg = "white" },
	style_c = { bg = "#001023", fg = "white" },

	permissions_t_fg = "green",
	permissions_r_fg = "yellow",
	permissions_w_fg = "red",
	permissions_x_fg = "cyan",
	permissions_s_fg = "darkgray",

	tab_width = 20,
	tab_use_inverse = true,

	selected = { icon = "󰻭", fg = "yellow" },
	copied = { icon = "", fg = "green" },
	cut = { icon = "", fg = "red" },

	total = { icon = "󰮍", fg = "yellow" },
	succ = { icon = "", fg = "green" },
	fail = { icon = "", fg = "red" },
	found = { icon = "󰮕", fg = "blue" },
	processed = { icon = "󰐍", fg = "green" },

	show_background = false,

	display_header_line = true,
	display_status_line = true,

	header_line = {
		left = {
			section_a = {
        			{type = "line", custom = false, name = "tabs", params = {"left"}},
			},
			section_b = {
        			{type = "coloreds", custom = false, name = "githead"},
			},
			section_c = {
			}
		},
		right = { section_a = { }, section_b = { }, section_c = {
				{type = "coloreds", custom = false, name = "task_states",},
		} }
	},

	status_line = {
		left = {
			section_a = {
        			{type = "string", custom = false, name = "tab_mode"},
			},
			section_b = {
        			{type = "string", custom = false, name = "hovered_size"},
        			{type = "string", custom = false, name = "hovered_name"},
        			{type = "coloreds", custom = false, name = "count"},
			},
			section_c = {
			}
		},
		right = {
			section_a = {
        			{type = "string", custom = false, name = "cursor_position"},
			},
			section_b = {
        			{type = "string", custom = false, name = "cursor_percentage"},
        			{type = "string", custom = false, name = "hovered_file_extension", params = {true}},
        			{type = "coloreds", custom = false, name = "permissions"},
			},
			section_c = {
			}
		}
	},
})

require("yatline-githead"):setup({
	branch_color = "green",
	branch_borders = "",
	branch_symbol = " ",
})
