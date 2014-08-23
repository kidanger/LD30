local LinkType = require 'linktype'

local function stats(f, n, t, g)
	local s = {}
	s[LinkType.nature]=n
	s[LinkType.technology]=t
	s[LinkType.food]=f
	s[LinkType.money]=g
	return s
end

local C = drystal.colors

return {
	{
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
			self:add_objective('Marseille needs some computers (20)!', function (map) return marseille:technology() >= 20 end)
		end,
	},
	{
		load=function (self)
			local a = self:add_city('A', 0, 0, stats(0, -1, 100, 0), C.darkslategray, true)
			local b = self:add_city('B', 290, 0, stats(100, -1, 0, 0), C.pink:darker())
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

