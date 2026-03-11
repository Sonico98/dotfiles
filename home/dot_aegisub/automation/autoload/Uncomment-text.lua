script_name = "Uncomment Text"
script_description = "Removes {} around plain text but keeps override tags"
script_author = "Copilot"
script_version = "1.0"

function uncomment_text(subs, sel)
	for _, i in ipairs(sel) do
		local line = subs[i]
		-- Replace {text} with text only if it doesn't contain a backslash (i.e., not an override tag)
		line.text = line.text:gsub("{([^\\}]-)}", "%1")
		subs[i] = line
	end
end

aegisub.register_macro("Uncomment Text", "Removes {} around plain text but keeps override tags", uncomment_text)
