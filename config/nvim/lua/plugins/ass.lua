-- arch1t3cht ass.nvim
return {
	"arch1t3cht/ass.nvim",
	ft = { "ass", "ssa" },
	config = function()
		require("ass").setup({
			conceal = false,
			mappings = true,
			remap = true,
			mpv_options_video = { "--pause" }, -- options passed to mpv when previewing video
			mpv_options_audio = { "--no-video", "--no-config", "--really-quiet" }, -- options passed to mpv when playing audio
			line_hook = function(line, oldline) -- Filter hook to be run on the results of split editing, or manually via :AssFilter
				return line
			end
		})
	end
}
