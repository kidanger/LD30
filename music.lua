local music = {
	songs={},
	req={},
	playing=nil,
	want=nil,
	sounds={},
}
local fade=0
local mute = false
local volume = 1
local hl = false

local mmm = {
	'intro.ogg',
	'm1.ogg',
	'm2.ogg',
	'm3.ogg',
	'm4.ogg',
}
function vol(v)
	volume = v
	if not mute then
		drystal.set_music_volume(v)
	end
end
function music.update(dt)
	if fade > 0 then
		if fade < 1 and fade + dt > 1 then
			for _, s in pairs(music.songs) do
				s:stop()
			end
			music.songs[music.playing]:play(true)
		end
		fade = fade + dt
		if fade > 1 then
			if fade > 2 then
				fade = 0
			else
				vol(fade - 1)
			end
		else
			vol(1 - fade)
		end
	end

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
	if music.req[1] == music.want and music.req[1] then
		drystal.set_alpha(lume.smooth(20, 150, math.sin(TIME*5)*.5+.5))
		drystal.set_color(200,200,200)
		smallfont:draw('Downloading music...', W*.01, H*.97)
	end
	if mute then
		drystal.set_color(150,150,150)
		if hl then
			drystal.set_alpha(100)
			drystal.draw_rect(W-50, 2, 48, 14)
		end
		drystal.set_alpha(255)
		drystal.draw_square(W-50, 2, 48, 14)
		drystal.set_color(255,255,255)
		smallfont:draw('Unmute', W-48, 3)
	else
		drystal.set_color(150,150,150)
		if hl then
			drystal.set_alpha(100)
			drystal.draw_rect(W-36, 2, 34, 14)
		end
		drystal.set_alpha(255)
		drystal.draw_square(W-36, 2, 34, 14)
		drystal.set_color(255,255,255)
		smallfont:draw('Mute', W-34, 3)
	end
end

function music.get(f)
	if lume.find(music.req, f) or music.songs[f] then
		print(f, 'already wgetting')
		return
	end
	table.insert(music.req, f)
	drystal.wget('musics/'..f, 'musics/'..f, function()
		print(f, 'wgetted')
		music.songs[f] = assert(drystal.load_music('musics/'..f))
		print(drystal.file_exists('musics/' .. f))
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
		if not drystal.file_exists('musics/' .. f) then
			if drystal.is_web then
				print('i dont have', f)
			else
				print(f, 'doesn\' exist')
			end
			return
		end
		print('load', f)
		music.songs[f] = assert(drystal.load_music('musics/' .. f))
	end
	if music.playing then
		--music.songs[music.playing]:stop()
		music.playing = nil
		fade = 0.001
	else
		fade = 0.999
	end

	--music.songs[f]:play(true)
	music.playing = f
	print('play?', f, fade)
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

function music.is_mute()
	return mute
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

