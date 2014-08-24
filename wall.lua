local Wall = class 'Wall'

function Wall:init(x, y, x2, y2)
	self.x = x
	self.y = y
	self.x2 = x2
	self.y2 = y2
end

function Wall:draw()
	drystal.set_alpha(lume.smooth(200, 255, math.sin(TIME*5)*.5+.5))
	drystal.set_color(drystal.colors.darkred)
	drystal.set_line_width(6)
	drystal.draw_line(self.x, self.y, self.x2, self.y2)
end

return Wall

