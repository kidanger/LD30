local LinkType = require 'linktype'
local City = require 'city'
local Objective = require 'objective'
local Link = require 'link'
local Map = class 'Map'

local function stats(f, n, t, g)
	local s = {}
	s[LinkType.nature]=n
	s[LinkType.technology]=t
	s[LinkType.food]=f
	s[LinkType.money]=g
	return s
end

function Map:init()
	self.links = {}
	self.possiblelinks = {}
	self.cities = {}
	self.objectives = {}

	self.capital = self:add_city('New York', 0, 0, stats(0, -1, -1, 50), true)
	self:add_city('Philadelphia', 260, -100, stats(80, -1, -1, 0))
	self:add_city('Nashua', 350, 180, stats(10, -1, -1, 0))

	self:add_objective('New York needs moar money (200)', function (map) return self.capital:money() >= 200 end)
	self:add_objective('Nashua need food to survive!', function (map) return self.capital:food() >= 70 end)
end

function Map:add_objective(...)
	local o = Objective:new(...)
	table.insert(self.objectives, o)
	return o
end

function Map:add_city(...)
	local c = City:new(...)
	for _, c2 in ipairs(self.cities) do
		self:add_possiblelink(c, c2)
	end
	table.insert(self.cities, c)
	return c
end

function Map:add_link(...)
	local l = Link:new(...)
	table.insert(self.links, l)
	return l
end
function Map:add_possiblelink(...)
	local l = Link:new(...)
	table.insert(self.possiblelinks, l)
	return l
end


function Map:update(dt)
	for _, l in ipairs(self.links) do
		l:update(dt)
	end
	for _, c in ipairs(self.cities) do
		c:update(dt)
	end
end

function Map:draw()
	for _, l in ipairs(self.links) do
		l:draw()
	end
	for _, l in ipairs(self.possiblelinks) do
		if l.hl then
			l:draw()
		end
	end

	for _, l in ipairs(self.possiblelinks) do
		if l.c1.selected or l.c2.selected then
			drystal.set_alpha(100)
			drystal.set_color(0,0,0)
			drystal.set_line_width(5)
			drystal.draw_line(l.c1.x, l.c1.y, l.c2.x, l.c2.y)
		end
	end
	for _, c in ipairs(self.cities) do
		c:draw()
	end
	for _, c in ipairs(self.cities) do
		c:draw2()
	end
end

function Map:get_city(name)
	for _, c in ipairs(self.cities) do
		if c.name == name then
			return c
		end
	end
end

function Map:get_link(c1, c2)
	for _, l in ipairs(self.links) do
		if l.c1 == c1 and l.c2 == c2 then
			return l
		end
		if l.c1 == c2 and l.c2 == c1 then
			return l
		end
	end
	for _, l in ipairs(self.possiblelinks) do
		if l.c1 == c1 and l.c2 == c2 then
			return l
		end
		if l.c1 == c2 and l.c2 == c1 then
			return l
		end
	end
end

return Map

