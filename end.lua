local state = {
	game=nil,
	i=0,
	j=0,
}

local function take(str, n)
	if n >= 1 then
		return str:sub(1, math.floor(n))
	else
		return ""
	end
end

function state:update(dt)
	if state.j < 1 then
		state.j = state.j + dt
		if state.j >= 1 then state.j = 1 end
	end
	if state.j == 1 then
		state.i = state.i + dt * 8
	end
end

function state:draw()
	state.game:draw()

	drystal.set_alpha(lume.smooth(0, 220, state.j))
	drystal.set_color(0,0,0)
	drystal.camera.reset()
	local w, h = drystal.screen.w, drystal.screen.h
	drystal.draw_rect(0, 0, w, h)

	drystal.set_alpha(255)
	drystal.set_color(255,255,255)

	local str = 'You rescued the cities!'
	local ww = bigfont:sizeof(str)
	bigfont:draw(take(str, state.i), w/2-ww/2, h*.35)
	if state.i - 10 >= #str then
		bigfont:draw('Thanks for playing!', w/2, h/2, 2)
	end
	if state.i - 30 >= #str then
		font:draw('by kidanger for Ludum Dare #30 (Connected Worlds)', w*.95, h*.9, 3)
	end
	if state.i - 50 >= #str then
		drystal.set_alpha(lume.smooth(20, 150, math.sin(TIME*5)*.5+.5))
		font:draw('Click or press space...', W*.5, H*.8, 2)
	end
end

function state:nnn()
	self.game.current_level = 0
	local menu = require 'menu'
	menu:init()
	set_state(menu)
end

function state:mouse_press(x, y, b)
	self:nnn()
end

function state:key_press(k)
	if k == 'space' then
		self:nnn()
	elseif k == 'b' then
		self.game.current_level = self.game.current_level - 1
		if self.game.current_level <= 0 then
			self.game.current_level = 1
		end
		set_state(self.game)
		self.game:restart()
	elseif k == 'n' then
		set_state(self.game)
		self.game:load_next_level()
	end
end

return state

