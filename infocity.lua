local LinkType = require 'linktype'

local infocity = {
}

function infocity.draw(c)
	local W, H = drystal.screen.w, drystal.screen.h
	local x1 = W * .75
	local x2 = W - 20
	local y1 = H * .75
	local y2 = H - 20

	drystal.set_alpha(150)
	drystal.set_color(drystal.colors.black)
	drystal.draw_rect(x1, y1, x2-x1, y2-y1)

	drystal.set_alpha(255)
	drystal.set_color(255,255,255)
	local y = y1
	font:draw(c.name, x1+10, y1+10)
	y = y + 50

	local t = LinkType.food
	repeat
		if c.stats[t] ~= -1 then
			smallfont:draw(t.name .. ': ' .. lume.round(c.stats[t]), x1+20, y)
		else
			smallfont:draw(t.name .. ': not accepted', x1+20, y)
		end
		y = y + 14
		t = t.next
	until t == LinkType.food
end

return infocity

