local LinkType = require 'linktype'
local Chat = require 'chat'

local function stats(f, n, t, g)
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

return {
	{
		on_enter=function(self)
			local phil = self.map:get_city('Philadelphia')
			local nash = self.map:get_city('Nashua')
			local c1 = Chat:new(self, {
				"Welcome! This is "..CC('New York', C.indianred)..".\nThis city needs money right now."..
				"\nConnect it to other cities to share resources.",
				'There is 4 types of links. A link can only tranfer\nresources of the same type.'
			}, self.map.capital.x, self.map.capital.y, W/2,H/2)
			local c2 = Chat:new(self, {
				CC('Philadelphia', phil.color).." produces "..CC('Food',LinkType.food.color)..'.'..
				"\nThe more it produces and stock "..CC('Food', LinkType.food.color)..',\nthe more it gains ' .. CC('Money', LinkType.money.color)..'.'
			}, phil.x, phil.y, W/2,H/2)
			local c3 = Chat:new(self, {
				'And here is '..CC('Nashua', nash.color)..". It needs "..CC('Food',LinkType.food.color)..', badly.',
				"Click on "..CC('Nashua', nash.color).." and link it to "..CC('Philadelphia', phil.color),
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
						'\nto ' .. CC('Nashua',nash.color) .. '.',
						'Restart the level using the top right button.'
					})
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
				local c = Chat:new(self, {
					'Great. Now look at the objectives.'..
					'\nYou have to '..CC('validate', C.green)..' each one in order to go\nto the next level.',
				}, nil, nil, W*.09,H*.19)
				set_state(c)
			end
		end,
		load=function (self)
			self.capital = self:add_city('New York', 0, 0, stats(-1, -1, -1, 0), C.indianred, true)
			local phil = self:add_city('Philadelphia', 260, -100, stats(80, -1, -1, 0), C.coral:lighter())
			local nash = self:add_city('Nashua', 450, 100, stats(0, -1, -1, 0), C.dodgerblue)
			self.capital.stats[LinkType.money] = 50
			nash.stats[LinkType.money] = 50

			self:add_objective('New York needs moar money (150)', function (map) return self.capital:money() >= 150 end)
			self:add_objective('Nashua needs food to survive! (50)', function (map) return nash:food() >= 50 end)
		end,
	},
	{
		load=function (self)
			self.capital = self:add_city('Paris', 0, 0, stats(0, -1, 0, 0), C.darkslategray, true)
			local nancy = self:add_city('Nancy', 290, 20, stats(50, -1, 0, 0), C.pink:darker())
			local marseille = self:add_city('Marseille', 150, 200, stats(10, -1, 0, 0), C.orange)
			local lille = self:add_city('Lille', 50, -200, stats(0, -1, 10, 0), C.green)

			self:add_objective('Paris wants food! (50)', function ()
				return self.capital:food() >= 50
			end)
			self:add_objective('Paris wants technology!! (30)', function ()
				return self.capital:technology() >= 30
			end)
			self:add_objective('Paris wants money!!! (200)', function ()
				return self.capital:money() >= 200
			end)
			self:add_objective('Marseille needs some computers! (20)', function (map) return marseille:technology() >= 20 end)
		end,
	},
	{
		load=function (self)
			local a = self:add_city('A', 0, 0, stats(0, -1, 100, 0), C.darkslategray, true)
			local b = self:add_city('B', 290, 0, stats(100, -1, 0, 0), C.pink:darker())
			local n = self:add_node('C', 145, 150, 0, C.black)
			self.capital = a

			self:add_objective('A wants food.', function (map)
				return a:food() > 50
			end)
			self:add_objective('B wants technology.', function (map)
				return b:technology() > 50
			end)
		end,
	},
}

