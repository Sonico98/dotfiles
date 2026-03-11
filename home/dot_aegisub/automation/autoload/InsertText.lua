-- InsertTextAtStart.lua
-- Aegisub Automation 4 script to insert user-defined text at the start of selected lines

script_name = "Insert Text at Start"
script_description = "Inserts specified text at the beginning of selected lines"
script_author = "Copilot"
script_version = "1.0"

include("karaskel.lua")

function insert_text(subs, sel)
	-- Prompt user for input
	local dialog_config = {
		{class="label", label="Text to insert at the start of each selected line:", x=0, y=0},
		{class="edit", name="insert_text", value="", x=0, y=1, width=300}
	}

	local buttons = {"OK", "Cancel"}
	local pressed, result = aegisub.dialog.display(dialog_config, buttons)

	if pressed == "Cancel" then return end

	local text_to_insert = result["insert_text"]

	for _, i in ipairs(sel) do
		local line = subs[i]
		if line.class == "dialogue" then
			line.text = text_to_insert .. line.text
			subs[i] = line
		end
	end
end

aegisub.register_macro(script_name, script_description, insert_text)
