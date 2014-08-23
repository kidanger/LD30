local LinkType = require 'linktype'
local Map = require 'map'
local infocity = require 'infocity'
local toolbar = require 'toolbar'
local objectives = require 'objectives'
local theend = require 'end'

local game = {
	map=nil,
	cx=150,
	cy=0,
	zoom=1,
	move=false,
	selectedcity=nil,
	hllink=nil,

	current_level=0,
	levels=require'levels'
}
local mx, my = W/2,H/2
local backcolor = drystal.colors.black:lighter():lighter()

theend.game = game

function game:init()
	self:load_next_level()
end

function game:load_next_level()
	if self.map then self.map.finished = false end
	self.current_level = self.current_level + 1
	local lvl = self.levels[self.current_level]
	if lvl then
		if lvl.on_enter then
			lvl.on_enter(self)
		end
		self.map = Map:new(lvl.load)
		local x, y = 0, 0
		for _, c in ipairs(self.map.cities) do
			x = x + c.x
			y = y + c.y
		end
		self.cx = x / #self.map.cities
		self.cy = y / #self.map.cities
	else
		set_state(theend)
	end
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
	local g = function(somey)
		return (endx - x) / (endy - y) * (somey - y) + x
	end
	return math.abs(f(px) - py) < radius or math.abs(g(py) - px) < radius
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
			local t = toolbar.type
			if c2.stats[t] == -1 or c.stats[t] == -1 then
				return
			end
			local l = self.map:get_link(c, c2)
			if not l.bought then
				l.type = toolbar.type
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
	toolbar.draw()

	objectives.draw(self.map)
	if self.map.finished then
		drystal.set_color(255,255,255)
		if self.current_level < #self.levels then
			bigfont:draw('Press Space to play the next level', 20, H*.9)
		else
			bigfont:draw('Press Space to end the game', 20, H*.9)
		end
	end

	drystal.camera.x = - self.cx + drystal.screen.w / 2
	drystal.camera.y = - self.cy + drystal.screen.h / 2
	drystal.camera.zoom = self.zoom
end

function game:key_press(k)
	if k == 'space' then
		if self.map.finished then
			self:load_next_level()
		end
	elseif k == 'y' then
		self:load_next_level()
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
	local t = toolbar.type
	if link.c2.stats[t] == -1 or link.c1.stats[t] == -1 then
		return
	end
	--self.map.capital.stats[LinkType.money] = self.map.capital.stats[LinkType.money] - 10
	local i = lume.find(self.map.possiblelinks, link)
	if i then
		table.remove(self.map.possiblelinks, i)
		table.insert(self.map.links, link)
		link.type = toolbar.type
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
			if not toolbar.mouse_press(x, y, b) then
				self:select_city(drystal.screen2scene(x, y))
			end
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
	toolbar.mouse_motion(x, y)
end

function game:mouse_release(x, y, b)
	if b == 3 then
		self.move = false
	elseif b == 4 then
		--self.zoom = self.zoom * 1.1
		toolbar.prev()
	elseif b == 5 then
		--self.zoom = self.zoom * .9
		toolbar.next()
	end
end

return game

