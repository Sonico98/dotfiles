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

require("git"):setup()

require("projects"):setup({
    save = {
        method = "yazi", -- yazi | lua
        yazi_load_event = "@projects-load", -- event name when loading projects in `yazi` method
        lua_save_path = "", -- path of saved file in `lua` method, comment out or assign explicitly
                            -- default value:
                            -- windows: "%APPDATA%/yazi/state/projects.json"
                            -- unix: "~/.local/state/yazi/projects.json"
    },
    last = {
        update_after_save = true,
        update_after_load = true,
        load_after_start = false,
    },
    merge = {
        event = "projects-merge",
        quit_after_merge = false,
    },
    event = {
        save = {
            enable = true,
            name = "project-saved",
        },
        load = {
            enable = true,
            name = "project-loaded",
        },
        delete = {
            enable = true,
            name = "project-deleted",
        },
        delete_all = {
            enable = true,
            name = "project-deleted-all",
        },
        merge = {
            enable = true,
            name = "project-merged",
        },
    },
    notify = {
        enable = true,
        title = "Projects",
        timeout = 3,
        level = "info",
    },
})
