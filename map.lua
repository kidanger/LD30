local LinkType = require 'linktype'
local City = require 'city'
local Node = require 'node'
local Wall = require 'wall'
local Objective = require 'objective'
local Link = require 'link'
local Map = class 'Map'

function Map:init(f)
	self.links = {}
	self.possiblelinks = {}
	self.cities = {}
	self.objectives = {}
	self.walls = {}
	self.finished = false
	f(self)
	self:bake()
end

local function ccw(x1, y1, x2, y2, x3, y3)
	return (y3-y1)*(x2-x1) > (y2-y1)*(x3-x1)
end

local function lineintersect(x1,y1,x2,y2,x3,y3,x4,y4)
	if x1 == x2 and x1 == x3 and x1 == x4 then
		return true
	end
	if y1 == y2 and y1 == y3 and y1 == y4 then
		return true
	end
	return ccw(x1, y1, x3, y3, x4, y4) ~= ccw(x2, y2, x3, y3, x4, y4) and ccw(x1, y1, x2, y2, x3, y3) ~= ccw(x1, y1, x2, y2, x4, y4)
end

function Map:bake()
	for i, c in ipairs(self.cities) do
		for j=i+1,#self.cities do
			local c2 = self.cities[j]
			local inter = false
			for _,w in ipairs(self.walls) do
				if lineintersect(c.x,c.y, c2.x, c2.y, w.x,w.y, w.x2, w.y2) then
					inter = true
				end
			end
			if not inter then
				self:add_possiblelink(c, c2)
			end
		end
	end
end

function Map:add_objective(...)
	local o = Objective:new(...)
	table.insert(self.objectives, o)
	return o
end

function Map:add_city(...)
	local c = City:new(...)
	table.insert(self.cities, c)
	return c
end

function Map:add_node(...)
	local n = Node:new(...)
	table.insert(self.cities, n)
	return n
end

function Map:add_wall(...)
	local w = Wall:new(...)
	table.insert(self.walls, w)
	return w
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
	for _, w in ipairs(self.walls) do
		w:draw()
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

