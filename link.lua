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
end

function Link:update(dt)
	if self.transfertime == -1 then
		local x1 = self.c1.stats[self.type] or 0
		local max1 = self.c1.maxstats[self.type] or 0
		local x2 = self.c2.stats[self.type] or 0
		local max2 = self.c2.maxstats[self.type] or 0

		if x1 < x2 and x1 / max1 < x2 / max2 then
			self.transfer = 2
			self.transfertime = 0
			local n = math.floor(self.c2.stats[self.type] * .1)
			self.amount = n
			self.c2.stats[self.type] = self.c2.stats[self.type] - n
		elseif x1 > x2 and x1 / max1 > x2 / max2 then
			self.transfer = 1
			self.transfertime = 0
			local n = math.floor(self.c1.stats[self.type] * .1)
			self.amount = n
			self.c1.stats[self.type] = self.c1.stats[self.type] - n
		end
	end
	if self.transfertime > -1 then
		self.transfertime = self.transfertime + dt
		if self.transfertime >= 1 then
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

	if self.transfer == 1 then
		drystal.set_color(self.type.color:lighter():lighter())
		local x = lume.smooth(self.c1.x, self.c2.x, self.transfertime)
		local y = lume.smooth(self.c1.y, self.c2.y, self.transfertime)
		drystal.set_point_size(8)
		drystal.draw_point(x, y)
	end
	if self.transfer == 2 then
		drystal.set_color(self.type.color:lighter():lighter())
		local x = lume.smooth(self.c2.x, self.c1.x, self.transfertime)
		local y = lume.smooth(self.c2.y, self.c1.y, self.transfertime)
		drystal.set_point_size(8)
		drystal.draw_point(x, y)
	end
end

return Link

