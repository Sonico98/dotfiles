-- Resize splits intuitively
return {
	"simeji/winresizer",
	cmd = "WinResizerStartResize",
	keys = {
		{ "<C-e>", "<Cmd>WinResizerStartResize<CR>", desc = "Resize splits" }
	}
}
