local music = {
	songs={},
	req={},
	playing=nil,
	want=nil,
}

local mmm = {
	'm1.ogg',
	'm2.ogg',
	'm3.ogg',
	'm4.ogg',
}
function music.update(dt)
	if not next(music.req) and drystal.is_web then
		for _, f in ipairs(mmm) do
			if not music.songs[f] then
				music.get(f)
				break
			end
		end
	end
end

function music.draw()
	if music.req[1] == music.want then
		drystal.set_alpha(lume.smooth(20, 150, math.sin(TIME*5)*.5+.5))
		drystal.set_color(200,200,200)
		font:draw('Downloading musics...', W*.01, H*.95)
	end
end

function music.get(f)
	if lume.find(music.req, f) then
		print(f, 'already wgetting')
	end
	table.insert(music.req, f)
	drystal.wget(f, f, function()
		print(f, 'wgetted')
		if music.want == f or not music.playing then
			music.play(f)
		end
		local i = lume.find(music.req, f)
		table.remove(music.req, i)
	end, function()
		local i = lume.find(music.req, f)
		table.remove(music.req, i)
		print(f, 'failed')
	end)
	print(f, 'wgetting')
end

function music.play(f)
	music.want=f
	if music.playing == f then
		print(f, 'already playing')
		return
	end
	if music.playing then
		music.songs[music.playing]:stop()
	end

	if not music[songs] then
		print('try load', f)
		if not drystal.file_exists(f) then
			if drystal.is_web then
				return
			else
				print(f, 'doesn\' exist')
			end
		end
		print('load', f)
		music.songs[f] = assert(drystal.load_music(f))
		print('OK load', f)
	end
	music.songs[f]:play(true)
	music.playing = f
	drystal.set_music_volume(0.2)
	print('play', f)
end

return music

