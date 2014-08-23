local LinkType = require 'linktype'

local toolbar = {
	selected=1,
	hl=0,
	type=LinkType.food,
}
local stuff = {
	{text="Food", type='food',color=LinkType.food.color},
	{text="Nature",type='nature',color=LinkType.nature.color},
	{text="Technology",type='technology',color=LinkType.technology.color},
	{text="Money", type='money',color=LinkType.money.color},
	--{text="Upgrade link", color=drystal.colors.red:lighter()},
}

local function show(text, state, x, y, w, h, color)
	local ww, hh = font:sizeof(text)
	drystal.set_color(color)
	drystal.set_alpha(30)
	if state == 2 then -- selected
		drystal.set_alpha(150)
	elseif state == 1 then -- hl
		drystal.set_alpha(100)
	end
	drystal.draw_rect(x, y, w, h)

	drystal.set_color(color)
	drystal.set_alpha(255)
	font:draw(text, x+w/2-ww/2, y+h/2-hh/2)
end

local w = 150
function toolbar.draw()
	for i, s in ipairs(stuff) do
		s.x = (w+10)*(i-1)+130
		show(s.text, toolbar.selected == i and 2 or (toolbar.hl == i and 1) or 0, s.x, 0, w, 40, s.color)
	end
end

function toolbar.mouse_press(x, y, b)
	if y > 40 then return false end
	for i, s in ipairs(stuff) do
		if x > s.x and x < s.x + w then
			toolbar.selected = i
			toolbar.type = LinkType[s.type]
			return true
		end
	end
end
function toolbar.mouse_motion(x, y)
	if y > 40 then return false end
	for i, s in ipairs(stuff) do
		if x > s.x and x < s.x + w then
			toolbar.hl = i
			return true
		end
	end
end

function toolbar.next()
	toolbar.selected = toolbar.selected % #stuff + 1
	toolbar.type = LinkType[stuff[toolbar.selected].type]
end

function toolbar.prev()
	toolbar.selected = (toolbar.selected - 2) % #stuff + 1
	toolbar.type = LinkType[stuff[toolbar.selected].type]
end

return toolbar

