-- use xrandr command to set output to best fitting fps rate
--  when playing videos with mpv.

utils = require 'mp.utils'

-- if you want your display output switched to a certain mode during playback,
--  use e.g. "--script-opts=xrandr-output-mode=1920x1080"
xrandr_output_mode = mp.get_opt("xrandr-output-mode")

xrandr_blacklist = {}
function xrandr_parse_blacklist()
   -- use e.g. "--script-opts=xrandr-blacklist=25" to have xrand.lua not use 25Hz refresh rate

	-- Parse the optional "blacklist" from a string into an array for later use.
	-- For now, we only support a list of rates, since the "mode" is not subject
	--  to automatic change (mpv is better at scaling than most displays) and
	--  this also makes the blacklist option more easy to specify:
	local b = mp.get_opt("xrandr-blacklist")
	if (b == nil) then
		return
	end
	
	local i = 1
	for s in string.gmatch(b, "([^, ]+)") do
		xrandr_blacklist[i] = 0.0 + s
		i = i+1
	end
end
xrandr_parse_blacklist()


function xrandr_check_blacklist(mode, rate)
	-- check if (mode, rate) is black-listed - e.g. because the
	--  computer display output is known to be incompatible with the
	--  display at this specific mode/rate 
	
	for i=1,#xrandr_blacklist do
		r = xrandr_blacklist[i]
		
		if (r == rate) then
			mp.msg.log("v", "will not use mode '" .. mode .. "' with rate " .. rate .. " because option --script-opts=xrandr-blacklist said so")
			return true
		end
	end
	
	return false
end

xrandr_detect_done = false
xrandr_modes = {}
xrandr_connected_outputs = {}
function xrandr_detect_available_rates()
	if (xrandr_detect_done) then
		return
	end
	xrandr_detect_done = true
	
	-- invoke xrandr to find out which fps rates are available on which outputs
	
	local p = {}
	p["cancellable"] = false
	p["args"] = {}
	p["args"][1] = "wlr-randr"
	local res = utils.subprocess(p)
	
	if (res["error"] ~= nil) then
		mp.msg.log("info", "failed to execute 'wlr-randr', error message: " .. res["error"])
		return
	end
	
	mp.msg.log("v","wlr-randr\n" .. res["stdout"])

	local output_idx = 1
	for output in string.gmatch(res["stdout"], '([^\n]+) \"') do
		
		table.insert(xrandr_connected_outputs, output)

		-- Untested with multiple outputs but should work
		local alltext = res["stdout"]
		local delim = "Position"
		local only_current_output_info = alltext:sub(1, alltext:find(delim, 1, true) - 1)
		
		local rates = ""
		for rate in string.gmatch(only_current_output_info, "(%d+%.%d+%*?%+?)") do
			rates = rates..rate.."   "
		end

		local wlr_output_to_xrandr = only_current_output_info
		wlr_output_to_xrandr = string.gsub(wlr_output_to_xrandr, "    ", "   ")
		wlr_output_to_xrandr = string.gsub(wlr_output_to_xrandr, "px,", "   ")
		wlr_output_to_xrandr = string.gsub(wlr_output_to_xrandr, " Hz", "")
		wlr_output_to_xrandr = string.gsub(wlr_output_to_xrandr, " %(preferred, current%)", "*+")
		wlr_output_to_xrandr = string.gsub(wlr_output_to_xrandr, " %(preferred%)", "+")
		wlr_output_to_xrandr = string.gsub(wlr_output_to_xrandr, " $(current%)", "*")
		-- the first line with a "*" after the match contains the rates associated with the current mode
		local mls = string.match(wlr_output_to_xrandr, " Modes.*")
		local r = rates
		local mode = nil
		local old_rate
		local old_mode
		
		-- old_rate = 0 means "no old rate known to switch to after playback"
		old_rate = 0
		
		if (xrandr_output_mode ~= nil) then		
			-- special case: user specified a certain preferred mode to use for playback
			mp.msg.log("v", "looking for refresh rates for user supplied output mode " .. xrandr_output_mode)
			mode = string.match(mls, '\n   (' .. xrandr_output_mode .. ') ([^\n]+)')
			
			if (mode == nil) then
				mp.msg.log("info", "user preferred output mode " .. xrandr_output_mode .. " not found for output " .. output .. " - will use current mode")
			else 
				mp.msg.log("info", "using user preferred xrandr_output_mode " .. xrandr_output_mode .. " for output " .. output)
				-- try to find the "old rate" for the other, currently active mode
				local oldr
				old_mode, oldr = string.match(mls, '\n   ([0-9x]+) ([^*\n]*%*[^\n]*)')
				if (oldr ~= nil) then
					for s in string.gmatch(oldr, "([^ ]+)%*") do
						old_rate = s
					end
				end
				mp.msg.log("v", "old_rate=" .. old_rate .. " found for old_mode=" .. tostring(old_mode))
			end
		end
		
		if (mode == nil) then
			-- normal case: use current mode
			mode = string.match(mls, '\n   ([0-9x]+) ([^*\n]*%*[^\n]*)')
			old_mode = mode
		end
		
		if (r == nil) then
			-- if no refresh rate is reported active for an output by xrandr,
			-- search for the mode that is "recommended" (marked by "+" in xrandr's output)
			mode = string.match(mls, '\n   ([0-9x]+) ([^+\n]*%+[^\n]*)')
			old_mode = mode
			if (r == nil) then 
				-- there is not even a "recommended" mode, so let's just use
				-- whatever first mode line there is
				mode, r = string.match(mls, '\n   ([0-9x]+) ([^+\n]*[^\n]*)')
			old_mode = mode
			end
		else
			-- Look for the rate that has *+ appended to it
			for s in string.gmatch(mls, "(%d+%.%d+%*%+)") do
				old_rate = string.gsub(s, "%*%+", "")
			end
		end
		mp.msg.log("info", "output " .. output .. " mode=" .. mode .. " old rate=" .. old_rate .. " refresh rates = " .. r)
		
		xrandr_modes[output] = { mode = mode, old_mode = old_mode, rates_s = r, rates = {}, old_rate = old_rate }
		local i = 1
		for s in string.gmatch(r, "([^ +*]+)") do
			
			-- check if rate "r" is black-listed - this is checked here because 
			if (not xrandr_check_blacklist(mode, 0.0 + s)) then
				xrandr_modes[output].rates[i] = 0.0 + s
				i = i+1
			end
		end
		
		output_idx = output_idx + 1
	end
	
end

function xrandr_find_best_fitting_rate(fps, output)
	
	local xrandr_rates = xrandr_modes[output].rates
	
  local best_fitting_rate = nil
  local best_fitting_ratio = math.huge
  
	-- try integer multipliers of 1 to 10 (given that high-fps displays exist these days)
	for m=1,10 do
		for i=1,#xrandr_rates do
			local r = xrandr_rates[i]
			local ratio = r / (m * fps)
      if (ratio < 1.0) then
        ratio = 1.0 / ratio
      end
      -- If the ratio is more than "very insignificantly off",
      -- then add a tiny additional score that will prefer faster
      -- over slower display frame rates, because those will cause
      -- shorter "stutters" when the display needs to skip or 
      -- duplicate one source frame.
      -- If the ratio is very close to 1.0, then we rather not
      -- choose the higher of the existing display rates, because
      -- displays performing frame interpolation work better when
      -- presented the actual, non-repeated source material frames.
      if (ratio > 1.0001) then
        ratio = ratio + (0.00000001 * (1000.0 - r))
      end
      -- mp.msg.log("info", "ratio " .. ratio .. " for r == " .. r)
      if (ratio < best_fitting_ratio) then
        best_fitting_ratio = ratio
        -- the xrand -q output may print nearby frequencies as the same
        -- rounded numbers - therefore, if our multiplier is == 1,
        -- we better return the video's frame rate, which xrandr
        -- is then likely to set the best rate for, even if the mode
        -- has some "odd" rate
        if (m == 1) then
          r = fps
        end
        best_fitting_rate = r
			end
		end		
	end
  
  return best_fitting_rate
end


xrandr_active_outputs = {}
function xrandr_set_active_outputs()
	local dn = mp.get_property("display-names")
	
	if (dn ~= nil) then
		mp.msg.log("v","display-names=" .. dn)
		xrandr_active_outputs = {}
		for w in (dn .. ","):gmatch("([^,]*),") do 
			table.insert(xrandr_active_outputs, w)
		end
	end
end

-- last detected non-nil video frame rate:
xrandr_cfps = nil

-- for each output, we remember which refresh rate we set last, so
-- we do not unnecessarily set the same refresh rate again
xrandr_previously_set = {}

function xrandr_set_rate()

	local f = mp.get_property_native("container-fps")
	if (f == nil or f == xrandr_cfps) then
		-- either no change or no frame rate information, so don't set anything
		return
	end
	xrandr_cfps = f

	xrandr_detect_available_rates()
	
	xrandr_set_active_outputs()
	
	local vdpau_hack = false
	local old_vid = nil
	local old_position = nil
	if (mp.get_property("options/vo") == "vdpau" or mp.get_property("options/hwdec") == "vdpau") then
		-- enable wild hack: need to close and re-open video for vdpau,
		-- because vdpau barfs if xrandr is run while it is in use
		
		vdpau_hack = true
		old_position = mp.get_property("time-pos")
		old_vid = mp.get_property("vid")
		mp.set_property("vid", "no")
	end

   -- unless "--script-opts=xrandr-ignore_unknown_oldrate=true" is set, 
	--  xrandr.lua will not touch display outputs for which it cannot
	--  get information on the current refresh rate for - assuming that
	--  such outputs are "disabled" somehow.
	local ignore_unknown_oldrate = mp.get_opt("xrandr-ignore_unknown_oldrate")
	if (ignore_unknown_oldrate == nil) then
		ignore_unknown_oldrate = false
	end

	
	local outs = {}
	if (#xrandr_active_outputs == 0) then
		-- No active outputs - probably because vo (like with vdpau) does
		-- not provide the information which outputs are covered.
		-- As a fall-back, let's assume all connected outputs are relevant.
		mp.msg.log("v","no output is known to be used by mpv, assuming all connected outputs are used.")
		outs = xrandr_connected_outputs
	else
		outs = xrandr_active_outputs
	end
		
	-- iterate over all relevant outputs used by mpv's output:
	for n, output in ipairs(outs) do
		
		if (ignore_unknown_oldrate == false and xrandr_modes[output].old_rate == 0) then
			mp.msg.log("info", "not touching output " .. output .. " because xrandr did not indicate a used refresh rate for it - use --script-opts=xrandr-ignore_unknown_oldrate=true if that is not what you want.")
		else
			local bfr = xrandr_find_best_fitting_rate(xrandr_cfps, output)

			if (bfr == 0.0) then
				mp.msg.log("info", "no non-blacklisted rate available, not invoking xrandr")
			else
				mp.msg.log("info", "container fps is " .. xrandr_cfps .. "Hz, for output " .. output .. " mode " .. xrandr_modes[output].mode .. " the best fitting display rate we will pass to xrandr is " .. bfr .. "Hz")

				if (bfr == xrandr_previously_set[output]) then
					mp.msg.log("v", "output " .. output .. " was already set to " .. bfr .. "Hz before - not changing")
				else 
					-- invoke xrandr to set the best fitting refresh rate for output 
					local p = {}
					p["cancellable"] = false
					p["args"] = {}
					p["args"][1] = "wlr-randr"
					p["args"][2] = "--output"
					p["args"][3] = output
					p["args"][4] = "--mode"
					p["args"][5] = xrandr_modes[output].mode.."@"..tostring(bfr).."Hz"

					local cmd_as_string = ""
					for k, v in pairs(p["args"]) do
						cmd_as_string = cmd_as_string .. v .. " "
					end
					mp.msg.log("debug", "executing as subprocess: \"" .. cmd_as_string .. "\"")
					local res = utils.subprocess(p)

					if (res["error"] ~= nil) then
						mp.msg.log("error", "failed to set refresh rate for output " .. output .. " using xrandr, error message: " .. res["error"])
					else
						xrandr_previously_set[output] = bfr
					end
				end
			end
		end
	end
	
	if (vdpau_hack) then
		mp.set_property("vid", old_vid)
		if (old_position ~= nil) then
    		mp.commandv("seek", old_position, "absolute", "keyframes")
		else
    		mp.msg.log("v", "old_position is 'nil' - not seeking after vdpau re-initialization")
		end
	end
end


function xrandr_set_old_rate()
	
	local outs = {}
	if (#xrandr_active_outputs == 0) then
		-- No active outputs - probably because vo (like with vdpau) does
		-- not provide the information which outputs are covered.
		-- As a fall-back, let's assume all connected outputs are relevant.
		mp.msg.log("v","no output is known to be used by mpv, assuming all connected outputs are used.")
		outs = xrandr_connected_outputs
	else
		outs = xrandr_active_outputs
	end
		
	-- iterate over all relevant outputs used by mpv's output:
	for n, output in ipairs(outs) do
		
		local old_rate = xrandr_modes[output].old_rate
		
		if (old_rate == 0 or xrandr_previously_set[output] == nil ) then
			mp.msg.log("v", "no previous frame rate known for output " .. output .. " - so no switching back.")
		else

			if (math.abs(old_rate-xrandr_previously_set[output]) < 0.001) then
				mp.msg.log("v", "output " .. output .. " is already set to " .. old_rate .. "Hz - no switching back required")
			else 

				mp.msg.log("info", "switching output " .. output .. " that was set for replay to mode " .. xrandr_modes[output].mode .. " at " .. xrandr_previously_set[output] .. "Hz back to mode " .. xrandr_modes[output].old_mode .. " with refresh rate " .. old_rate .. "Hz")

				-- invoke xrandr to set the best fitting refresh rate for output 
				local p = {}
				p["cancellable"] = false
				p["args"] = {}
				p["args"][1] = "wlr-randr"
				p["args"][2] = "--output"
				p["args"][3] = output
				p["args"][4] = "--mode"
				p["args"][5] = xrandr_modes[output].old_mode.."@"..old_rate.."Hz"

				local res = utils.subprocess(p)

				if (res["error"] ~= nil) then
					mp.msg.log("error", "failed to set refresh rate for output " .. output .. " using xrandr, error message: " .. res["error"])
				else
					xrandr_previously_set[output] = old_rate
				end
			end
		end
		
	end
	
end

-- we'll consider setting refresh rates whenever the video fps or the active outputs change:
mp.observe_property("container-fps", "native", xrandr_set_rate)
mp.observe_property("display-names", "native", xrandr_set_rate)

-- and we'll try to revert the refresh rate when mpv is shut down
mp.register_event("shutdown", xrandr_set_old_rate)

