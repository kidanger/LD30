drystal = require 'drystal'

if drystal.is_web then
	drystal.run_js('document.getElementById("load").style.display="none";')
	drystal.run_js('document.getElementById("canvas").style.display="block";')
end

W = 900
H = 600
drystal.resize(W, H)
smallfont = drystal.load_font('font.ttf', 14)
font = drystal.load_font('font.ttf', 26)
bigfont = drystal.load_font('font.ttf', 38)
vbigfont = drystal.load_font('font.ttf', 58)

class = require 'middleclass'
lume = require 'lume'
tween = require 'tween'
local music = require 'music'

local game = require 'game'
local data = drystal.fetch('links')
if data then
	--game.current_level = data.lvl
	if data.mute then music.mute() end
end
local menu = require 'menu'

local state = menu

function set_state(st)
	state = st
end

state:init()

TIME = 0
function drystal.update(dt)
	TIME = TIME + dt
	state:update(dt)
	music.update(dt)
end

function drystal.draw()
	drystal.set_color(255, 255, 255)
	drystal.set_alpha(255)
	drystal.draw_background()

	state:draw()
	music.draw()
	drystal.camera.reset()
	if state.set_cam then
		state:set_cam()
	end
end

function drystal.key_press(k)
	if state.key_press then
		state:key_press(k)
	end
end

function drystal.key_release(k)
	if state.key_release then
		state:key_release(k)
	end
	if k == 'm' then
		music.mute()
	end
end

function drystal.mouse_press(...)
	if music.mouse_press(...) then
		return
	end
	if state.mouse_press then
		state:mouse_press(...)
	end
end

function drystal.mouse_release(...)
	if state.mouse_release then
		state:mouse_release(...)
	end
end

function drystal.mouse_motion(...)
	if state.mouse_motion then
		state:mouse_motion(...)
	end
	music.mouse_motion(...)
end
function drystal.atexit()
	drystal.store('links', {lvl=game.current_level-1,mute=music.is_mute()})
end
