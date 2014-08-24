local LinkType = require 'linktype'

local objectives = {
}

function objectives.draw(map)
	drystal.set_alpha(255)
	drystal.set_color(220, 220, 220)
	local x, y = 5, 75
	font:draw('{shadowx:2|shadowy:3|Objectives:}', x, y)
	y = y + 30
	x = x + 20
	local allgood = true
	for i, o in ipairs(map.objectives) do
		if o.condition(map) then
			drystal.set_color(drystal.colors.green)
		else
			drystal.set_color(drystal.colors.red)
			allgood = false
		end
		smallfont:draw('- ' .. o.expl, x, y)
		y = y + 20
	end
	if allgood then
		map.finished = true
	end
end

return objectives

