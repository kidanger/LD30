local LinkType = class 'LinkType'

function LinkType:init(name, color)
	self.name = name
	self.color = color
end

local types = {
	nature=LinkType:new('Nature', drystal.colors.green),
	technology=LinkType:new('Technology', drystal.colors.grey),
	food=LinkType:new('Food', drystal.colors.orange),
	money=LinkType:new('Money', drystal.colors.yellow),
}

types.nature.next = types.technology
types.technology.next = types.money
types.food.next = types.nature
types.money.next = types.food

return types

