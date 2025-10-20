script_name = "Split at \\N"
script_description = "Splits a line at \\N into two events"
script_author = "Copilot"
script_version = "1.9"

-- Manual deep copy function
function deep_copy_line(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

-- Extract leading tags/comments from the start of the line
function extract_leading_tags(text)
    local tags = ""
    while text:match("^%b{}") do
        local tag = text:match("^(%b{})")
        tags = tags .. tag
        text = text:gsub("^%b{}", "", 1)
    end
    return tags
end

-- Remove all tags/comments from a string
function strip_tags(text)
    return text:gsub("(%b{})", "")
end

-- Find first \N outside of any {...} block
function find_visible_break(text)
    local i = 1
    local inside_brace = false
    while i <= #text - 1 do
        local c = text:sub(i, i)
        local next_c = text:sub(i + 1, i + 1)

        if c == "{" then
            inside_brace = true
        elseif c == "}" then
            inside_brace = false
        elseif c == "\\" and next_c == "N" and not inside_brace then
            return i
        end
        i = i + 1
    end
    return nil
end


-- Snap time to nearest keyframe within threshold
function snap_to_keyframe(time_ms, keyframes, threshold)
    local closest = time_ms
    local min_diff = threshold + 1

    for _, frame in ipairs(keyframes) do
        local kf_time = aegisub.ms_from_frame(frame)
        local diff = math.abs(kf_time - time_ms)
        if diff < min_diff then
            closest = kf_time
            min_diff = diff
        end
    end

    if min_diff <= threshold then
        return closest
    else
        return time_ms
    end
end


-- Split at midpoint
function split_midpoint(subs, sel)
	local keyframes = aegisub.keyframes()
    local threshold = 500  -- milliseconds
    for _, i in ipairs(sel) do
        local line = subs[i]
        local text = line.text

        local split_pos = find_visible_break(text)
        if not split_pos then
            aegisub.log("Line %d has no \\N, skipping.\n", i)
        else
            -- Split the text at the first \N
            local before = text:sub(1, split_pos - 1)  -- exclude \N
            local after = text:sub(split_pos + 2)      -- start right after \N

            -- Extract leading tags/comments from the original line
            local leading_tags = extract_leading_tags(text)

            -- Calculate midpoint
            local midpoint = math.floor((line.start_time + line.end_time) / 2)
			local snapped_midpoint = snap_to_keyframe(midpoint, keyframes, threshold)

            -- Create first line (keep original before part as-is)
            local line1 = deep_copy_line(line)
            line1.text = before
            line1.end_time = snapped_midpoint

            -- Create second line (prepend leading tags)
            local line2 = deep_copy_line(line)
            line2.text = leading_tags .. after
            line2.start_time = snapped_midpoint

            -- Replace original line with first part
            subs[i] = line1
            -- Insert second part right after
            subs.insert(i + 1, line2)
        end
    end
end

-- Split with auto-balanced timing
function split_balanced(subs, sel)
	local keyframes = aegisub.keyframes()
    local threshold = 500  -- milliseconds
    for _, i in ipairs(sel) do
        local line = subs[i]
        local text = line.text

        local split_pos = find_visible_break(text)
        if not split_pos then
            aegisub.log("Line %d has no \\N, skipping.\n", i)
        else
            -- Split the text at the first \N
            local before = text:sub(1, split_pos - 1)  -- exclude \N
            local after = text:sub(split_pos + 2)      -- start right after \N

            -- Extract leading tags/comments from the original line
            local leading_tags = extract_leading_tags(text)

			-- Strip tags to count visible characters
			local before_visible = strip_tags(before)
			local after_visible = strip_tags(after)

			local len_before = string.len(before_visible)
			local len_after = string.len(after_visible)
			local total_len = len_before + len_after

			if total_len == 0 then total_len = 1 end -- avoid division by zero

            -- Calculate proportional timing
            local duration = line.end_time - line.start_time
            local dur_before = math.floor(duration * (len_before / total_len))
			local raw_split_time = line.start_time + dur_before
            local snapped_split_time = snap_to_keyframe(raw_split_time, keyframes, threshold)

            -- Create first line
            local line1 = deep_copy_line(line)
            line1.text = before
            line1.end_time = snapped_split_time

            -- Create second line
            local line2 = deep_copy_line(line)
            line2.text = leading_tags .. after
            line2.start_time = snapped_split_time

            -- Replace original line with first part
            subs[i] = line1
            -- Insert second part right after
            subs.insert(i + 1, line2)
        end
    end
end

aegisub.register_macro("Split on Break/Midpoint", "Splits at \\N using midpoint timing", split_midpoint)
aegisub.register_macro("Split on Break/Auto-balanced", "Splits at \\N using character-based timing", split_balanced)

