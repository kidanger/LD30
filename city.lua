local LinkType = require 'linktype'
local City = class 'City'

function City:init(name, x, y, maxstats, initstats)
	self.name = name
	self.color = drystal.new_color('hsl', math.random(360), 0.5, 0.6)
	self.colordark = self.color:lighter():lighter()
	self.x = x
	self.y = y
	self.maxstats = maxstats or {}
	self.stats = lume.clone(initstats or {})
	for _, t in pairs(LinkType) do
		self.stats[t] = self.stats[t] or 0
		self.maxstats[t] = self.maxstats[t] or 0
	end
	self.size = 64
	self.selected = false
end

function City:update(dt)
end

function City:draw()
	local t = math.floor(TIME * 5)
	if self.selected and t % 2 == 0 then
		drystal.set_color(self.colordark)
	else
		drystal.set_color(self.color)
	end
	drystal.set_alpha(255)
	drystal.draw_rect(self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
end

local function drawvalue(self, t, dx, dy)
	drystal.set_color(LinkType[t].color:darker():darker():darker())
	local a, b = self[t](self)
	local str = '-'
	if b ~= 0 then
		str = tostring(math.floor(100*a/b)) .. '%'
	end
	local w, h = smallfont:sizeof(str)
	local x = self.x + self.size*dx*.2
	local y = self.y + self.size*dy*.34
	x = x - w / 2
	y = y - h / 2
	smallfont:draw('{shadowx:1|shadowy:1|'..str..'}', x, y)
end

function City:draw2()
	drystal.set_alpha(255)

	drawvalue(self, 'nature', -1, -1)
	drawvalue(self, 'technology', 1, -1)
	drawvalue(self, 'food', -1, 1)
	drawvalue(self, 'money', 1, 1)

	drystal.set_color(255,255,255)
	local w, h = smallfont:sizeof(self.name)
	smallfont:draw('{shadowx:1|shadowy:1|'..self.name..'}', self.x-w/2, self.y-h/2)
end

function City:nature()
	return self.stats[LinkType.nature], self.maxstats[LinkType.nature]
end
function City:technology()
	return self.stats[LinkType.technology], self.maxstats[LinkType.technology]
end
function City:food()
	return self.stats[LinkType.food], self.maxstats[LinkType.food]
end
function City:money()
	return self.stats[LinkType.money], self.maxstats[LinkType.money]
end

return City

