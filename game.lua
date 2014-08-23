local LinkType = require 'linktype'
local Node = require 'linktype'
local Map = require 'map'
local infocity = require 'infocity'
local toolbar = require 'toolbar'
local objectives = require 'objectives'
local theend = require 'end'

local game = {
	map=nil,
	cx=0,
	cy=0,
	ccx=0,
	ccy=0,
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
		self.map = Map:new(lvl.load)
		self:center_cam()
		self.selectedcity=nil
		if lvl.on_enter then
			lvl.on_enter(self)
		end
	else
		set_state(theend)
	end
end

function game:center_cam()
	local x, y = 0, 0
	for _, c in ipairs(self.map.cities) do
		x = x + c.x
		y = y + c.y
	end
	self.cx = x / #self.map.cities
	self.cy = y / #self.map.cities
end

function game:restart()
	if self.map then self.map.finished = false end
	local lvl = self.levels[self.current_level]
	if lvl then
		self.map = Map:new(lvl.load)
		self:center_cam()
		self.selectedcity=nil
		if lvl.on_enter then
			lvl.on_enter(self)
		end
	else
		set_state(theend)
	end
end

function game:update(dt)
	self.map:update(dt)
	if self.selectedcity then
		self:try_hl_link()
	end
end

-- http://stackoverflow.com/a/2233538
function nearline(x1, y1, x2, y2, x3, y3, d)
	local px = x2-x1
	local py = y2-y1
	local something = px*px + py*py
	local u =  ((x3 - x1) * px + (y3 - y1) * py) / something
	if u > 1 then
		u = 1
	elseif u < 0 then
		u = 0
	end
	local x = x1 + u * px
	local y = y1 + u * py
	local dx = x - x3
	local dy = y - y3
	local dist = dx*dx + dy*dy
	return dist <= d
end

function game:try_hl_link()
	if self.hllink then
		self.hllink.hl = false
		self.hllink = nil
	end
	local c = self.selectedcity
	local x, y = drystal.screen2scene(mx, my)

	if math.distance(x, y, c.x, c.y) < c.size*math.sqrt(2)/2 then
		return
	end
	for _, c2 in ipairs(self.map.cities) do
		if c ~= c2 and nearline(c.x, c.y, c2.x, c2.y, x, y, 10) and math.distance(x,y,c2.x,c2.y) > c2.size*math.sqrt(2)/2 then
			local t = toolbar.type
			if not c2:want(t) or not c:want(t) then
				return
			end
			local l = self.map:get_link(c, c2)
			if l and not l.bought then
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

	self.ccx = self.ccx + (self.cx-self.ccx)*.2
	self.ccy = self.ccy + (self.cy-self.ccy)*.2
	drystal.camera.x = - self.ccx + drystal.screen.w / 2
	drystal.camera.y = - self.ccy + drystal.screen.h / 2
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
	do
		local bx, by = W-100, 75
		drystal.set_color(0,0,0)
		if self.hlrestart then
			drystal.set_alpha(100)
			drystal.draw_rect(bx, by, W-bx-5, 35)
		end
		drystal.set_alpha(255)
		drystal.set_line_width(2)
		drystal.draw_square(bx, by, W-bx-5, 35)
		drystal.set_alpha(255)
		drystal.set_color(255,255,255)
		font:draw('Restart', bx+10, by+6)
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
	if not link.c2:want(t) or not link.c1:want(t) then
		return
	end
	local c1count = 1
	if link.c1.is_node then
		for _, l in ipairs(self.map.links) do
			if l.c1 == link.c1 or l.c2 == link.c1 then
				c1count = c1count + 1
			end
		end
	end
	local c2count = 1
	if link.c2.is_node then
		for _, l in ipairs(self.map.links) do
			if l.c1 == link.c2 or l.c2 == link.c2 then
				c2count = c2count + 1
			end
		end
	end

	local i = lume.find(self.map.possiblelinks, link)
	if i then
		table.remove(self.map.possiblelinks, i)
		table.insert(self.map.links, link)
		link.type = toolbar.type
		link.bought = true
		if link.on_buy then
			link:on_buy(self)
		end
		local j = 1
		while j <= #self.map.possiblelinks do
			local l = self.map.possiblelinks[j]
			print(link.c1, l.c1,l.c2)
			if c1count == 2 and (l.c1 == link.c1 or l.c2 == link.c1) then
				self.map.possiblelinks[j] = self.map.possiblelinks[#self.map.possiblelinks]
				self.map.possiblelinks[#self.map.possiblelinks] = nil
				j = j - 1
			elseif c2count == 2 and (l.c1 == link.c2 or l.c2 == link.c2) then
				self.map.possiblelinks[j] = self.map.possiblelinks[#self.map.possiblelinks]
				self.map.possiblelinks[#self.map.possiblelinks] = nil
				j = j - 1
			end
			j = j + 1
		end
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

	do
		self.hlrestart = false
		local bx, by = W-100, 75
		if x > bx and y > by and x < W-5 and y < by+35 then
			self.hlrestart = true
		end
	end
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
	elseif b == 1 then
		do
			local bx, by = W-100, 75
			if x > bx and y > by and x < W-5 and y < by+35 then
				self:restart()
			end
		end
	end
end

return game

