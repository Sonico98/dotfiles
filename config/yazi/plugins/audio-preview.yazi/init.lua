local M = {}

function M:peek()
	local cache = ya.file_cache(self)
	if not cache then
		return
	end

	local child = Command("exiftool")
		:args({
			"-q", "-q", "-S", "-Title", "-SortName",
			"-Titlesort", "-TitleSortOrder", "-Artist",
			"-SortArtist", "-Artistsort", "-PerformerSortOrder",
			"-Album", "-SortAlbum", "-Albumsort", "-AlbumSortOrder",
			"-AlbumArtist", "-SortAlbumArtist", "-AlbumArtistsort",
			"-AlbumArtistSortOrder", "-Genre", "-TrackNumber",
			"-Year", "-Duration", "-SampleRate", "-AudioSampleRate",
			"-AudioBitrate", "-AvgBitrate", "-Channels",
			"-AudioChannels", tostring(self.file.url),
		})
		:stdout(Command.PIPED)
		:stderr(Command.NULL)
		:spawn()

	local limit = self.area.h
	local i, metadata = 0, ""
	repeat
		local next, event = child:read_line()
		if event == 1 then
			return self:fallback_to_builtin()
		elseif event ~= 0 then
			break
		end

		i = i + 1
		if i > self.skip then
			metadata = metadata .. next
		end
	until i >= self.skip + limit

	metadata = prettify_metadata(metadata)

	-- Show the cover art only if the preview pane is not hidden
	local cover_width = 0
	local cover_height = 0
	if self.area.right ~= self.area.x then
		cover_width = self.area.right / 6
		cover_height = self.area.bottom / 3
	end

	local bottom_right = ui.Rect {
		x = self.area.right - cover_width,
		y = self.area.bottom - cover_height,
		w = cover_width,
		h = cover_height,
	}

	if self:preload() == 1 then
		ya.preview_widgets(self, { ui.Paragraph.parse(self.area, metadata) })
		ya.image_show(cache, bottom_right)
	end
end

function prettify_metadata(metadata)
	local substitutions = {
		SortName = "\nSort Title:",
		Titlesort = "\nSort Title:",
		TitleSortOrder = "\nSort Title:",
		Artist = "\nArtist:",
		SortArtist = "\nSort Artist:",
		Artistsort = "\nSort Artist:",
		ArtistSort = "\nSort Artist:",
		PerformerSortOrder = "\nSort Artist:",
		Album = "\nAlbum:",
		SortAlbum = "\nSort Album:",
		Albumsort = "\nSort Album:",
		ALBUMSORT = "\nSort Album:",
		AlbumSortOrder = "\nSort Album:",
		AlbumArtist = "\nAlbum Artist:",
		SortAlbumArtist = "\nSort Album Artist:",
		AlbumArtistsort = "\nSort Album Artist:",
		AlbumArtistSortOrder = "\nSort Album Artist:",
		Genre = "\nGenre:",
		GENRE = "\nGenre:",
		TrackNumber = "\nTrack Number:",
		Year = "\nYear:",
		Duration = "\nDuration:",
		SampleRate = "\nSample Rate:",
		AudioBitrate = "\nBitrate:",
		AvgBitrate = "\nAverage Bitrate:",
		Channels = "\nChannels:",
	}

	for k, v in pairs(substitutions) do
		metadata = metadata:gsub(tostring(k) .. ":", v, 1)
	end
	-- Exceptions, because they contain a new line in their name
	metadata = metadata:gsub("Audio\nSample Rate:", "\nSample Rate:")
	metadata = metadata:gsub("Audio\nChannels:", "\nChannels:")
	return metadata
end

function M:seek(units)
	local h = cx.active.current.hovered
	if h and h.url == self.file.url then
		ya.manager_emit("peek", {
			tostring(math.max(0, cx.active.preview.skip + units)),
			only_if = tostring(self.file.url),
		})
	end
end

function M:preload()
	local cache = ya.file_cache(self)
	if not cache or fs.cha(cache) then
		return 1
	end

	local output = Command("exiftool")
		:args({ "-b", "-CoverArt", "-Picture", tostring(self.file.url) })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()

	if not output then
		return 0
	end

	return fs.write(cache, output.stdout) and 1 or 2
end
return M
