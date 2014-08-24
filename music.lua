local music = {
	songs={},
	req={},
	playing=nil,
	want=nil,
	sounds={},
}
local mute = false
local volume = 1
local hl = false

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
		smallfont:draw('Downloading music...', W*.01, H*.97)
	end
	drystal.set_color(150, 150, 150)
	drystal.set_alpha(255)
	drystal.set_line_width(1)
	if mute then
		if hl then
			drystal.draw_rect(W-50, 2, 48, 14)
		end
		drystal.draw_square(W-50, 2, 48, 14)
		smallfont:draw('Unmute', W-48, 3)
	else
		if hl then
			drystal.draw_rect(W-36, 2, 34, 14)
		end
		drystal.draw_square(W-36, 2, 34, 14)
		smallfont:draw('Mute', W-34, 3)
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
	if not music[songs] then
		print('try load', f)
		if not drystal.file_exists(f) then
			if drystal.is_web then
				print('i dont have', f)
				return
			else
				print(f, 'doesn\' exist')
			end
		end
		print('load', f)
		music.songs[f] = assert(drystal.load_music(f))
		print('OK load', f)
	end
	if music.playing then
		music.songs[music.playing]:stop()
		music.playing = nil
	end

	music.songs[f]:play(true)
	music.playing = f
	if mute then
		drystal.set_music_volume(0)
	else
		drystal.set_music_volume(volume)
	end
	print('play', f)
end

function music.mouse_motion(x, y)
	hl = false
	if x > W-50 and y < 20 then
		hl = true
	end
end

function music.mouse_press(x, y, b)
	if b == 1 then
		if x > W-50 and y < 20 then
			music.mute()
			return true
		end
	end
end

function music.plop(s, vol)
	if not music.sounds[s] then
		music.sounds[s] = assert(drystal.load_sound(s))
	end
	music.sounds[s]:play(vol or 1)
end

function music.mute()
	mute = not mute
	if mute then
		drystal.set_music_volume(0)
	else
		drystal.set_music_volume(volume)
	end
end

return music

