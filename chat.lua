local Chat = class 'Chat'

function Chat:init(game, texts, cx, cy, sx, sy)
	self.game = game
	self.next = state
	self.texts = texts
	self.cx = cx
	self.cy = cy
	self.sx = sx
	self.sy = sy
	self.i = 1
end

function Chat:update(dt)
	self.time = self.time or TIME
end

function Chat:draw()
	if self.cx then
		self.game.cx = self.cx
		self.game.cy = self.cy
	end
	self.game:draw()

	if self.fade then
		drystal.set_alpha(lume.smooth(0, 120, (TIME-self.time)*2))
	else
		drystal.set_alpha(120)
	end
	drystal.set_color(0,0,0)
	drystal.camera.reset()
	local w, h = drystal.screen.w, drystal.screen.h
	drystal.draw_rect(0, 0, w, h)

	drystal.set_alpha(150)
	drystal.set_color(drystal.colors.black)
	drystal.draw_rect(W*.015,H*.7,W*.970,H*.28)

	if self.sx then
		drystal.draw_triangle(W*.3, H*.7, W*.4, H*.7, self.sx, self.sy)
	end

	drystal.set_alpha(255)
	drystal.set_color(255,255,255)
	bigfont:draw(self.texts[self.i], W*.03, H*.72)

	local t = math.floor(TIME*3)
	if TIME-self.time > 2 then
		drystal.set_alpha(lume.smooth(20, 150, math.sin(TIME*5)*.5+.5))
		drystal.set_color(255,255,255)
		font:draw('Click or press space...', W*.973, H*.935, 3)
	end
end

function Chat:nnn()
	if self.i < #self.texts then
		self.i = self.i + 1
	else
		if not self.next then
			self.game:center_cam()
		end
		set_state(self.next or self.game)
	end
end

function Chat:mouse_press(x, y, b)
	self:nnn()
end

function Chat:key_press(k)
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

return Chat

