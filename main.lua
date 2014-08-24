drystal = require 'drystal'

W = 900
H = 600
drystal.resize(W, H)
smallfont = drystal.load_font('font.ttf', 14)
font = drystal.load_font('font.ttf', 26)
bigfont = drystal.load_font('font.ttf', 38)

class = require 'middleclass'
lume = require 'lume'
tween = require 'tween'
local music = require 'music'

local state = require 'game'

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
end

function drystal.mouse_press(...)
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
end

