local LinkType = require 'linktype'
local Link = class 'Link'

function Link:init(c1, c2)
	self.c1 = c1
	self.c2 = c2
	self.color = drystal.colors.black
	self.hl = false
	self.bought = false
	self.type = nil
	self.transfer = 0
	self.transfertime = -1
	self.amount = 0
	self.distance = math.distance(c1.x, c1.y, c2.x, c2.y)
	self.wait = lume.random(2)
end

function Link:update(dt)
	if self.wait > 0 then
		self.wait = self.wait - dt
		return
	end
	if self.transfertime == -1 then
		local x1 = self.c1.stats[self.type] or 0
		local x2 = self.c2.stats[self.type] or 0
		--if self.c1:need(self.type, self.c2) then
		if self.c1.needs then
			x1 = x1 - self.c1.needs[self.type]
		end
		--end
		--if self.c2:need(self.type, self.c1) then
		if self.c2.needs then
			x2 = x2 - self.c2.needs[self.type]
		end
		--end

		if x1 < x2 then
			local n = math.floor(x2 * self.c2.give)
			if n > 0 then
				self.amount = n
				self.c2.stats[self.type] = self.c2.stats[self.type] - n
				self.transfer = 2
				self.transfertime = 0
			end
		elseif x1 > x2 then
			local n = math.floor(x1 * self.c1.give)
			if n > 0 then
				self.transfer = 1
				self.transfertime = 0
				self.amount = n
				self.c1.stats[self.type] = self.c1.stats[self.type] - n
			end
		end
	end

	if self.transfertime > -1 then
		self.transfertime = self.transfertime + 300*dt
		if self.transfertime >= self.distance then
			self.transfertime = -1
			if self.transfer == 1 then
				self.c2.stats[self.type] = self.c2.stats[self.type] + self.amount
			else
				self.c1.stats[self.type] = self.c1.stats[self.type] + self.amount
			end
		end
	end
end

function Link:draw()
	drystal.set_color(self.type.color)
	if self.hl then
		drystal.set_alpha(lume.smooth(100, 255, math.sin(TIME*15)*.5+.5))
	else
		drystal.set_alpha(255)
	end

	drystal.set_line_width(5)
	drystal.draw_line(self.c1.x, self.c1.y, self.c2.x, self.c2.y)

	local xx = self.transfertime / self.distance
	if self.transfer == 1 then
		drystal.set_color(self.type.color:lighter():lighter())
		local x = lume.smooth(self.c1.x, self.c2.x, xx)
		local y = lume.smooth(self.c1.y, self.c2.y, xx)
		drystal.draw_point(x, y, 8)
		local x = lume.smooth(self.c1.x, self.c2.x, xx - 0.016*1)
		local y = lume.smooth(self.c1.y, self.c2.y, xx - 0.016*1)
		drystal.draw_point(x, y, 6)
		local x = lume.smooth(self.c1.x, self.c2.x, xx + 0.016*1)
		local y = lume.smooth(self.c1.y, self.c2.y, xx + 0.016*1)
		drystal.draw_point(x, y, 6)
	end
	if self.transfer == 2 then
		drystal.set_color(self.type.color:lighter():lighter())
		local x = lume.smooth(self.c2.x, self.c1.x, xx)
		local y = lume.smooth(self.c2.y, self.c1.y, xx)
		drystal.draw_point(x, y, 8)
		local x = lume.smooth(self.c2.x, self.c1.x, xx - 0.016*1)
		local y = lume.smooth(self.c2.y, self.c1.y, xx - 0.016*1)
		drystal.draw_point(x, y, 6)
		local x = lume.smooth(self.c2.x, self.c1.x, xx + 0.016*1)
		local y = lume.smooth(self.c2.y, self.c1.y, xx + 0.016*1)
		drystal.draw_point(x, y, 6)
	end
end

return Link

