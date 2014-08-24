local LinkType = require 'linktype'
local game = require 'game'
local Map = require 'map'
local music = require 'music'

local menu = {
}

local function stats(f, n, t, g)
	local s = {}
	--s[LinkType.nature]=n
	s[LinkType.technology]=t
	s[LinkType.food]=f
	s[LinkType.money]=g
	return s
end

function menu:init()
	music.play('intro.ogg')
	local n = 6
	local map = Map:new(function(map)
		local mx = 350
		local my = 200
		for i=0, n do
			local x, y
			repeat
				local ok = true
				x, y = math.random(-mx,mx), math.random(-my,my)
				for _,c in ipairs(map.cities) do
					if math.distance(c.x,c.y, x, y) < 150 then
						ok = false
					end
				end
			until ok
			local c = map:add_city('', x, y, stats(math.random(0, 100), math.random(0, 100), math.random(0,100), math.random(0, 100)), drystal.new_color('hsl', math.random(0,360), math.random(), math.random()))
		end
	end)
	self.map = map
	for i=0,n*n/3 do
		if #map.possiblelinks == 0 then
			break
		end
		local j = math.floor(lume.random(1, #map.possiblelinks))
		local l = map.possiblelinks[j]
		table.remove(map.possiblelinks, j)
		table.insert(map.links, l)
		l.type = LinkType[lume.randomchoice(lume.array(pairs(LinkType)))]
		l.bought = true
	end
	self:center_cam()
end

function menu:center_cam()
	local x, y = 0, 0
	for _, c in ipairs(self.map.cities) do
		x = x + c.x
		y = y + c.y
	end
	self.cx = x / #self.map.cities
	self.cy = y / #self.map.cities
	self.ccx = self.cx
	self.ccy = self.cy
end


function menu:update(dt)
	self.map:update(dt)
end

local backcolor = drystal.colors.black:lighter():lighter()
function menu:draw()
	drystal.set_alpha(255)
	drystal.set_color(backcolor)
	drystal.draw_background()

	self.ccx = self.ccx + (self.cx-self.ccx)*.2
	self.ccy = self.ccy + (self.cy-self.ccy)*.2
	drystal.camera.x = - self.ccx + drystal.screen.w / 2
	drystal.camera.y = - self.ccy + drystal.screen.h / 2

	self.map:draw()
	drystal.camera.reset()

	drystal.set_color(220,220,220)
	drystal.set_alpha(255)
	local w,h = bigfont:sizeof('{shadowx:3|shadowy:3|Rescue the cities}')
	bigfont:draw('{shadowx:3|shadowy:3|Rescue the cities}', W*.5-w/2, H*.03)

	local t = math.floor(TIME*3)
	if TIME > 2 then
		drystal.set_alpha(lume.smooth(20, 150, math.sin(TIME*5)*.5+.5))
		drystal.set_color(255,255,255)
		font:draw('Click or press space...', W*.973, H*.935, 3)
	end
end

function menu:key_press(k)
	if k == 'space' or k == 'return' then
		set_state(game)
		game:init()
	end
end

function menu:mouse_press(x, y, b)
	if b == 1 then
		set_state(game)
		game:init()
	end
end

return menu

