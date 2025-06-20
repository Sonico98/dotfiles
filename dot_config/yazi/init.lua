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
