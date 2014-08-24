local LinkType = require 'linktype'
local Node = class 'Node'

function Node:init(name, x, y)
	self.name = name
	self.x = x
	self.y = y
	self.size = 32
	self.is_node = true
	self.stats = {}
	for _, t in pairs(LinkType) do
		self.stats[t] = 0
	end
	self.give=1
end

function Node:update(dt)
end

function Node:draw()
end
function Node:draw2()
	drystal.set_alpha(255)
	drystal.set_color(100,100,100)
	drystal.draw_circle(self.x, self.y, self.size/2+2)

	drystal.set_alpha(200)
	drystal.set_color(200,200,200)
	drystal.draw_circle(self.x, self.y, lume.lerp(self.size/3, self.size/2, math.sin(TIME)*.5+.5))
end

function Node:want(t)
	return true
end

function Node:need(t, from)
	if self.c1 == from then
		return self.c2:need(t, self)
	elseif self.c2 == from then
		return self.c2:need(t, self)
	end
	return false
end

return Node

