package.path = BASE_PATH.."/Contents/Resources/?.lua"
package.cpath = BASE_PATH.."/Contents/Frameworks/?.so"

require"cairo"

-- the controller should set VIEWPORT_WIDTH and VIEWPORT_HEIGHT before executing this file
cs = cairo_quartz_surface_create(CAIRO_FORMAT_ARGB32, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
cr = cairo_create(cs)
cgc = cairo_quartz_surface_get_cg_context(cs)

-- the controller should also register a SET_CAIRO_CONTEXT function
-- to provide the viewport object with our CGContext
SET_CAIRO_CONTEXT(VIEWPORT, cgc)

-- convenience method for table defaults

defaults = function(t, d)
  t = t or {}
  setmetatable(t, d)
  d.__index = d
  return t
end

-- some convenience constants

Color = {}
Color.black = {r=0, g=0, b=0, a=1}
Color.white = {r=1, g=1, b=1, a=1}
Color.red = {r=1, g=0, b=0, a=1}
Color.green = {r=0, g=1, b=0, a=1}
Color.blue = {r=0, g=0, b=1, a=1}
Color.random = function()
  return {r=math.random(), g=math.random(), b=math.random(), a=1}
end

Point = {}
Point.zero = {x=0, y=0}

-- the Cairo object: where the drawing action's at

Cairo = {}
Cairo.mt = {}

Cairo.prototype = {
	cr = nil,
	bounds = {x=0, y=0, width=0, height=0},
	color = {r=1, g=1, b=1, a=1},
	clear = function(self, color)
		self.color = color or Color.white
		self:rectangle(self.bounds)
		self:fill()
	end,
	-- path functions
	rectangle = function(self, rect)
		cairo_rectangle(self.cr, rect.x, rect.y, rect.width, rect.height)
	end,
	circle = function(self, circ)
		cairo_arc(self.cr, circ.x, circ.y, circ.r, 0, 2 * math.pi)
	end,
	moveTo = function(self, point)
		cairo_move_to(self.cr, point.x, point.y)
	end,
	lineTo = function(self, point)
		cairo_line_to(self.cr, point.x, point.y)
	end,
	moveBy = function(self, vec)
		cairo_rel_move_to(self.cr, vec.dx, vec.dy)
	end,
	lineBy = function(self, vec)
		cairo_rel_line_to(self.cr, vec.dx, vec.dy)
	end,
	-- drawing functions
	fill = function(self, save)
		cairo_set_source_rgba(self.cr, self.color.r, self.color.g, self.color.b, self.color.a)
		if save then cairo_fill_preserve(self.cr) else cairo_fill(self.cr) end
		VIEWPORT_NEEDS_DISPLAY(VIEWPORT)
	end,
	stroke = function(self, save)
		cairo_set_source_rgba(self.cr, self.color.r, self.color.g, self.color.b, self.color.a)
		if save then cairo_stroke_preserve(self.cr) else cairo_stroke(self.cr) end
		VIEWPORT_NEEDS_DISPLAY(VIEWPORT)
	end,
	text = function(self, text, attrs)
		attrs = defaults(attrs, {size=16, color=Color.black, x=16, y=16})
		cairo_select_font_face(self.cr, "sans-serif", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
		cairo_set_font_size(self.cr, attrs.size)
		cairo_set_source_rgba(cr, attrs.color.r, attrs.color.g, attrs.color.b, attrs.color.a)
		cairo_move_to(self.cr, attrs.x, attrs.y)
		cairo_show_text(self.cr, text)
		VIEWPORT_NEEDS_DISPLAY(VIEWPORT)
	end
}
Cairo.mt.__index = Cairo.prototype

Cairo.new = function(c)
	c = c or {}
	setmetatable(c, Cairo.mt)
	return c
end

c = Cairo.new{cr=cr, bounds={x=0, y=0, width=VIEWPORT_WIDTH, height=VIEWPORT_HEIGHT}}

-- event handling

Responders = {}

mouseDown = function(x, y)
	for _, v in pairs(Responders) do
		if v:hitTest(x, y) and v:respondsTo("mouseDown") then v:mouseDown(x, y) end
	end
end

mouseUp = function(x, y)
	for _, v in pairs(Responders) do
		if v:hitTest(x, y) and v:respondsTo("mouseUp") then v:mouseUp(x, y) end
	end
end

-- Responders

Responder = {}
Responder.mt = {}

Responder.prototype = {
	bounds = {x=0, y=0, width=0, height=0},
	events = {},
	hitTest = function(self, x, y)
		return		(0 < x - self.bounds.x)
				and (x - self.bounds.x < self.bounds.width)
				and (0 < y - self.bounds.y)
				and (y - self.bounds.y < self.bounds.height)
	end,
	respondsTo = function(self, evt)
		for _, v in pairs(self.events) do if evt == v then return true end end
	end
}
Responder.mt.__index = Responder.prototype

Responder.new = function(r)
	r = r or {}
	setmetatable(r, Responder.mt)
	table.insert(Responders, r)
	return r
end

Button = {}
Button.mt = {}

Button.prototype = {
	events = {"mouseDown", "mouseUp"},
	pushed = false,
	title = "Button",
	draw = function(self)
		c:rectangle(self.bounds)
		if self.pushed then c.color = Color.red else c.color = Color.white end
		c:fill(true)
		c.color = Color.black
		c:stroke()
		c:text(self.title, {size = 16, x = self.bounds.x + 5, y = self.bounds.y + self.bounds.height/2 + 8})
	end,
	mouseDown = function(self, x, y)
		self.pushed = true
		self:draw()
	end,
	mouseUp = function(self, x, y)
		self:action()
		self.pushed = false
		self:draw()
	end,
	action = function(self) end
}
Button.mt.__index = Button.prototype
setmetatable(Button.prototype, Responder.mt)

Button.new = function(b)
	b = b or {}
	setmetatable(b, Button.mt)
	table.insert(Responders, b)
	b:draw()
	return b
end

