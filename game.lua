local LinkType = require 'linktype'
local Map = require 'map'
local infocity = require 'infocity'

local game = {
	map=nil,
	cx=150,
	cy=0,
	zoom=1,
	move=false,
	selectedcity=nil,
	hllink=nil,
	linktype=LinkType.nature,

	money=1000,
}
game.__index = game
local mx, my = W/2,H/2
local backcolor = drystal.colors.black:lighter():lighter()

function game:init()
	self.map = Map:new()
end

TIME = 0
function game:update(dt)
	TIME = TIME + dt
	self.map:update(dt)
	if self.selectedcity then
		self:try_hl_link()
	end
end

function nearline(x, y, endx, endy, px, py, radius)
	if x > endx then
		x, endx = endx, x
		y, endy = endy, y
	end
	local f = function(somex)
		return (endy - y) / (endx - x) * (somex - x) + y
	end
	return math.abs(f(px) - py) < radius and px >= x and px <= endx
end

function game:try_hl_link()
	if self.hllink then
		self.hllink.hl = false
		self.hllink = nil
	end
	local c = self.selectedcity
	local x, y = drystal.screen2scene(mx, my)

	for _, c2 in ipairs(self.map.cities) do
		if c ~= c2 and nearline(c.x, c.y, c2.x, c2.y, x, y, 6) then
			local l = self.map:get_link(c, c2)
			if not l.bought then
				l.type = self.linktype
				self.hllink = l
				self.hllink.hl = true
				break
			end
		end
	end
end

function game:draw()
	drystal.set_color(backcolor)
	drystal.draw_background()

	drystal.camera.x = - self.cx + drystal.screen.w / 2
	drystal.camera.y = - self.cy + drystal.screen.h / 2
	drystal.camera.zoom = self.zoom

	self.map:draw()
	drystal.camera.reset()

	if self.selectedcity then
		infocity.draw(self.selectedcity)
	end

	drystal.camera.x = - self.cx + drystal.screen.w / 2
	drystal.camera.y = - self.cy + drystal.screen.h / 2
	drystal.camera.zoom = self.zoom
end

function game:key_press(k)
	if k == 'a' then
		drystal.stop()
	elseif k == 'b' then
		self.linktype = self.linktype.next
		print(self.linktype.name)
	end
end

function game:select_city(x, y)
	if self.selectedcity then
		self.selectedcity.selected = false
		self.selectedcity = nil
		if self.hllink then
			self.hllink.hl = false
			self.hllink = nil
		end
	end
	for _, c in ipairs(self.map.cities) do
		if math.distance(x, y, c.x, c.y) < c.size*math.sqrt(2)/2 then
			self.selectedcity = c
			self.selectedcity.selected = true
			break
		end
	end
end

function game:buy_link(link)
	self.money = self.money - 100
	local i = lume.find(self.map.possiblelinks, link)
	if i then
		table.remove(self.map.possiblelinks, i)
		table.insert(self.map.links, link)
		link.type = self.linktype
		link.bought = true
	end
end

function game:mouse_press(x, y, b)
	if b == 3 then
		self.move = true
	elseif b == 1 then
		if self.hllink then
			self:buy_link(self.hllink)
			self.hllink.hl = false
			self.hllink = nil
		else
			self:select_city(drystal.screen2scene(x, y))
		end
	end
end

function game:mouse_motion(x, y, dx, dy)
	if self.move then
		self.cx = self.cx - dx
		self.cy = self.cy - dy
	end
	mx = x
	my = y
end

function game:mouse_release(x, y, b)
	if b == 3 then
		self.move = false
	elseif b == 4 then
		self.zoom = self.zoom * 1.1
	elseif b == 5 then
		self.zoom = self.zoom * .9
	end
end

return game

