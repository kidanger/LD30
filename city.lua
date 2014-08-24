local LinkType = require 'linktype'
local City = class 'City'

function City:init(name, x, y, initstats, color, is_capital)
	self.name = name
	self.color = color or drystal.new_color('hsl', math.random(360), 0.5, 0.6)
	self.colordark = self.color:lighter():lighter()
	self.x = x
	self.y = y
	self.stats = lume.clone(initstats or {})
	self.produces = initstats or {}
	self.needs = {}
	for _, t in pairs(LinkType) do
		self.stats[t] = self.stats[t] or 0
		self.needs[t] = 0
	end
	self.is_capital = is_capital
	self.size = is_capital and 80 or 50
	self.selected = false
	self.give=.2
end

function City:update(dt)
	for t, n in pairs(self.produces) do
		if n > 0 then
			if self.stats[t] > 0 then
				self.stats[t] = self.stats[t] + dt
			end
			--if self.stats[t] > 200 then
				--self.stats[t] = 200
			--end
		end
	end
end

function City:draw()
	drystal.set_alpha(255)
	drystal.set_color(self.colordark)
	drystal.draw_rect(self.x - self.size / 2 - 2, self.y - self.size / 2 - 2, self.size+4, self.size+4)

	local t = math.floor(TIME * 5)
	if self.selected and t % 2 == 0 then
		drystal.set_color(self.colordark)
	else
		drystal.set_color(self.color)
	end
	drystal.draw_rect(self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
end

local function drawvalue(self, t, dx, dy)
	drystal.set_color(LinkType[t].color:darker():darker():darker())
	local a = self[t](self)
	local str = '-'
	if a ~= -1 then
		str = tostring(lume.round(a))
	end
	local w, h = smallfont:sizeof(str)
	local x = self.x + self.size*dx*.3
	local y = self.y + self.size*dy*.34
	x = x - w / 2
	y = y - h / 2
	if self.produces[LinkType[t]] > 0 then
		smallfont:draw('{shadowx:1|shadowy:1|'..str..'}{r:0|b:0|g:' .. lume.smooth(0, 200, math.sin(TIME)*.5+.5).. '| +}', x, y)
	elseif self.needs[LinkType[t]] > self.stats[LinkType[t]] then
		smallfont:draw('{shadowx:1|shadowy:1|'..str..'}{g:0|b:0|r:' .. lume.smooth(0, 200, math.sin(TIME)*.5+.5).. '| x}', x, y)
	else
		smallfont:draw('{shadowx:1|shadowy:1|'..str..'}', x, y)
	end
end

function City:draw2()
	drystal.set_alpha(255)

	drawvalue(self, 'food', 0, -1)
	--drawvalue(self, 'nature', 1, -1)
	drawvalue(self, 'technology', 0, 0)
	drawvalue(self, 'money', 0, 1)

	drystal.set_color(255,255,255)
	local w, h = font:sizeof(self.name)
	font:draw('{shadowx:2|shadowy:2|'..self.name..'}', self.x-w/2, self.y-self.size/2-h*1.3)

	if self.is_capital then
		local w, h = smallfont:sizeof('Capital')
		smallfont:draw('{shadowx:1|shadowy:1|Capital}', self.x-w/2, self.y+self.size/2+h/2)
	end
end

function City:nature()
	return self.stats[LinkType.nature]
end
function City:technology()
	return self.stats[LinkType.technology]
end
function City:food()
	return self.stats[LinkType.food]
end
function City:money()
	return self.stats[LinkType.money]
end

function City:want(t)
	return self.stats[t] ~= -1
end

function City:need(t, from)
	return self.needs[t] > 0 and self.needs[t]*(1+self.give) >= self.stats[t]
end

return City

