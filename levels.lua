local LinkType = require 'linktype'
local Chat = require 'chat'
local music = require 'music'

local function stats(f, t, g)
	local s = {}
	--s[LinkType.nature]=n
	s[LinkType.technology]=t
	s[LinkType.food]=f
	s[LinkType.money]=g
	return s
end

local C = drystal.colors
local function CC(text, color)
	return ('{r:%d|g:%d|b:%d|' .. text .. '}'):format(unpack(color))
end
local M = LinkType.money
local F = LinkType.food
local T = LinkType.technology

return {
	{
		on_enter=function(self)
			music.play('m1.ogg')
			local phil = self.map:get_city('Philadelphia')
			local nash = self.map:get_city('Boston')
			local ny = self.map:get_city('New York')
			local c1 = Chat:new(self, {
				"Welcome! This is "..CC('New York', C.indianred)..".\nThis city needs money right now."..
				"\nConnect it to other cities to share resources.",
				'There is 3 types of links. A link can only tranfer\nresources of the same type.'
			}, self.map.capital.x, self.map.capital.y, W/2,H/2)
			local c2 = Chat:new(self, {
				CC('Philadelphia', phil.color).." produces "..CC('Food',LinkType.food.color)..' and '..CC('Money', LinkType.money.color) .. '.'
			}, phil.x, phil.y, W/2,H/2)
			local c3 = Chat:new(self, {
				'And here is '..CC('Boston', nash.color)..". It needs "..CC('Food',LinkType.food.color)..', badly.',
				"Click on "..CC('Boston', nash.color).." and link it to "..CC('Philadelphia', phil.color),
			}, nash.x, nash.y, W/2,H/2)
			c1.next = c2
			c2.next = c3
			c1.fade=true
			set_state(c1)

			local l = self.map:get_link(nash, phil)
			l.on_buy = function(l, self)
				if l.type == LinkType.money then
					local c = Chat:new(self, {
						'Err, I think you made a mistake. You had to use the\n'..CC('Food Link',LinkType.food.color)..
						' in order to transfer '..CC('Food',LinkType.food.color).. ' from '..CC('Philadelphia', phil.color)..
						'\nto ' .. CC('Boston',nash.color) .. '.',
						'Restart the level using the top right button.'
					}, nil, nil, W*.9,80)
					set_state(c)
				else
					local c = Chat:new(self, {
						"Good. Now click on "..CC('Philadelphia', phil.color)..' and link it to\n'..CC('New York', C.indianred)..
						' with the '..CC('Money Link', LinkType.money.color)..'.'
					}, nil, nil, W*.6,H*.05)
					set_state(c)
				end
			end
			local l = self.map:get_link(self.map.capital, phil)
			l.on_buy = function(l, self)
				if l.type == LinkType.money then
					local c = Chat:new(self, {
						'Great. Now look at the objectives.'..
						'\nYou have to '..CC('validate', C.green)..' each one in order to go\nto the next level.',
					}, nil, nil, W*.09,H*.19)
					set_state(c)
				else
					local c = Chat:new(self, {
						'Err, I think you made a mistake. You had to use the\n'..CC('Money Link',LinkType.money.color)..
						' in order to transfer '..CC('Money',LinkType.money.color).. ' from '..CC('Philadelphia', phil.color)..
						'\nto ' .. CC('New York',ny.color) .. '.',
						'Restart the level using the top right button.'
					}, nil, nil, W*.89,100)
					set_state(c)
				end
			end
		end,
		load=function (self)
			self.capital = self:add_city('New York', 0, 0, stats(0, -1, 0), C.indianred, true)
			local phil = self:add_city('Philadelphia', 260, -100, stats(80, -1, 90), C.coral:lighter())
			local nash = self:add_city('Boston', 450, 100, stats(0, -1, 0), C.dodgerblue)
			self.capital.stats[LinkType.money] = 50
			self.capital.needs[M] = 150
			nash.needs[F] = 50

			self:add_objective('New York needs moar money (150)', function (map) return self.capital:money() >= 150 end)
			self:add_objective('Boston needs food to survive! (50)', function (map) return nash:food() >= 50 end)
		end,
	},

	{
		on_enter=function(self)
			music.play('m1.ogg')
			local c1 = Chat:new(self, {
				"Well done! This level is a bit more difficult.\nYou have to use the third resource: " .. CC('Technology', T.color) .. '.'
			})
			c1.fade=true
			set_state(c1)
		end,
		load=function (self)
			local paris = self:add_city('Paris', 0, 0, stats(0, 0, 0), C.darkslategray, true)
			self.capital = paris
			local nancy = self:add_city('Nancy', 290, 20, stats(50, 0, 0), C.pink:darker())
			local marseille = self:add_city('Marseille', 150, 200, stats(10, 0, 50), C.orange)
			local lille = self:add_city('Lille', 50, -200, stats(0, 10, 0), C.green, false)
			paris.needs[F] = 50
			paris.needs[T] = 30
			paris.needs[M] = 20
			marseille.needs[T] = 20

			self:add_objective('Paris wants food! (50)', function ()
				return self.capital:food() >= paris.needs[F]
			end)
			self:add_objective('Paris wants technology!! (30)', function ()
				return self.capital:technology() >= paris.needs[T]
			end)
			self:add_objective('Paris wants money!!! (20)', function ()
				return self.capital:money() >= paris.needs[M]
			end)
			self:add_objective('Marseille needs some computers! (20)', function (map) return marseille:technology() >= marseille.needs[T] end)
		end,
	},

	{
		on_enter=function(self)
			music.play('m2.ogg')
			local c1 = Chat:new(self, {
				'This thing is a node.\nIt can only have 2 links connected to it.'
			}, nil, nil, W*.5, H*.65)
			c1.fade=true
			set_state(c1)
		end,
		load=function (self)
			local a = self:add_city('Frozen City', 0, 0, stats(0, 40, 0), C.darkslategray)
			local b = self:add_city('Farmville', 290, 0, stats(40, 0, 0), C.pink:darker())
			local n = self:add_node('Node', 145, 150)
			a.needs[F] = 50
			b.needs[T] = 50
			self:auto_objectives()
		end,
	},

	{
		on_enter=function(self)
			music.play('m2.ogg')
			local c1 = Chat:new(self, {
				'And that is a WALL! Bouh, walls are bad!'
			}, nil, nil, W*.5, H*.55)
			c1.fade=true
			set_state(c1)
		end,
		load=function (self)
			local a = self:add_city('West Berlin', 0, 0, stats(0, 40, 0), C.darkslategray)
			local b = self:add_city('East Berlin', 290, 0, stats(40, 0, 0), C.pink:darker())
			local n = self:add_node('Node', 145, 150)
			local n = self:add_node('Node', 145, -150)
			local w = self:add_wall(145, -100, 145, 100)
			a.needs[F] = 50
			b.needs[T] = 50

			self:auto_objectives()
		end,
	},

	{
		on_enter=function(self)
			music.play('m3.ogg')
		end,
		load=function (self)
			music.play('m4.ogg')
			local sing = self:add_city('Singapore', 0, 250, stats(0, 0, 0), C.darkslategray)
			local tokyo = self:add_city('Tokyo', 400, 0, stats(0, 0, 50), C.pink:darker())
			local hong = self:add_city('Hong Kong', 0, 0, stats(0,50,0), C.lightblue)
			local hanoi = self:add_city('Hanoi', 400, 250, stats(0,0,0), C.lightgreen)
			local w = self:add_wall(200, -150, 200, 70)
			local w = self:add_wall(200, 160, 200, 450)
			tokyo.needs[T] = 50
			hong.needs[M] = 50

			self:auto_objectives()
		end,
	},

	{
		on_enter=function(self)
			music.play('m3.ogg')
		end,
		load=function (self)
			local c1 = self:add_city('Brazil', 0, 0, stats(50, 50, 0), C.yellow:lighter():lighter())
			local c2 = self:add_city('Salvador', 350, -50, stats(0, 0, 0), C.goldenrod)
			local c3 = self:add_city('Rio de Janeiro', 420, 220, stats(0, 0, 0), C.khaki)
			local w = self:add_wall(200, -150, 200, 30)
			local n = self:add_node('Node', 200, 260)
			local n = self:add_node('Node', -50, 220)
			c2.needs[T] = 50
			c3.needs[T] = 50
			c2.needs[F] = 50
			c3.needs[F] = 50

			self:auto_objectives()
		end,
	},

	{
		on_enter=function(self)
			music.play('m3.ogg')
		end,
		load=function (self)
			local c1 = self:add_city('A', 0, 0, stats(9000, 9000, 9000), C.white)
			local c2 = self:add_city('B', 450, -150, stats(0, 0, 0), C.white)
			local c3 = self:add_city('C', 420, 220, stats(0, 0, 0), C.white)
			local c4 = self:add_city('D', 620, 220, stats(0, 0, 0), C.white)
			local w = self:add_wall(230, -250, 230, -50)
			local w = self:add_wall(230, 50, 230, 350)
			local w = self:add_wall(410, 100, 590, 100)
			local n = self:add_node('Node', 150, -110)
			local n = self:add_node('Node', 350, -150)
			local n = self:add_node('Node', 310, 0)
			local n = self:add_node('Node', 600, -150)
			local n = self:add_node('Node', (c3.x+c4.x)/2, (c3.y+c4.y)/2+50)
			c2.needs[T] = 500
			c3.needs[T] = 500
			c4.needs[T] = 500
			c2.needs[M] = 500
			c3.needs[M] = 500
			c4.needs[M] = 500

			self:add_objective('Everycity wants technology! (500)', function (map)
				return c1:technology() >= 500
				and c2:technology() >= 500
				and c3:technology() >= 500
			end)
			self:add_objective('Everycity wants money! (500)', function (map)
				return c1:money() >= 500
				and c2:money() >= 500
				and c3:money() >= 500
			end)
			self:add_objective('Nocity wants food. :(', function (map)
				return true
			end)
		end,
	},
}

