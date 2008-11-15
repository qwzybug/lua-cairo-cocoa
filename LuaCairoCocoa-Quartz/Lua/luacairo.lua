require"cairo"

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
Color.transparent = {r=0, g=0, b=0, a=0}
Color.fade = function(c, a) return {r=c.r, g=c.g, b=c.b, a=a*c.a} end
Color.gray = function(l)
  l = l or 0.5
  return {r=l, g=l, b=l, a=1}
end
Color.random = function()
  return {r=math.random(), g=math.random(), b=math.random(), a=1}
end

Point = {}
Point.zero = {x=0, y=0}

-- the Cairo object: where the drawing action's at

Cairo = {}
Cairo.mt = {}

Cairo.prototype = {
	clear = function(self, color)
		self.color = color or Color.white
		self:rectangle(self.bounds)
		self:fill()
	end,
	erase = function(self)
	  cairo_save(self.cr)
	  self:rectangle(self.bounds)
	  self.color = Color.transparent
  	cairo_set_operator(self.cr, CAIRO_OPERATOR_SOURCE)
  	self:fill()
  	cairo_restore(self.cr)
	end,
	-- path functions
	rectangle = function(self, rect)
		cairo_rectangle(self.cr, rect.x, rect.y, rect.width, rect.height)
	end,
	roundRect = function(self, rect, r)
	  r = r or 4
	  self:moveTo{x = rect.x, y = rect.y + r}
	  cairo_arc(self.cr, rect.x+r, rect.y+r, r, math.pi, 3 * math.pi / 2)
	  self:lineTo{x = rect.x + rect.width - r, y = rect.y}
	  cairo_arc(self.cr, rect.x + rect.width - r, rect.y + r, r, 3 * math.pi/2, 0)
	  self:lineTo{x = rect.x + rect.width, y = rect.y + rect.height - r}
	  cairo_arc(self.cr, rect.x + rect.width - r, rect.y + rect.height - r, r, 0, math.pi / 2)
	  self:lineTo{x = rect.x + r, y = rect.y + rect.height}
	  cairo_arc(self.cr, rect.x + r, rect.y + rect.height - r, r, math.pi / 2, math.pi)
	  self:lineTo{x = rect.x, y = rect.y + r}
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
	end,
	stroke = function(self, save)
		cairo_set_source_rgba(self.cr, self.color.r, self.color.g, self.color.b, self.color.a)
		if save then cairo_stroke_preserve(self.cr) else cairo_stroke(self.cr) end
	end,
	text = function(self, text, attrs)
		attrs = defaults(attrs, {size=16, color=Color.black, x=16, y=16})
		cairo_select_font_face(self.cr, "sans-serif", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
		cairo_set_font_size(self.cr, attrs.size)
		cairo_set_source_rgba(self.cr, attrs.color.r, attrs.color.g, attrs.color.b, attrs.color.a)
		cairo_move_to(self.cr, attrs.x, attrs.y)
		cairo_show_text(self.cr, text)
	end,
	paintSurface = function(self, other_ctxt, bounds)
		cairo_set_source_surface(self.cr, other_ctxt.cs, bounds.x, bounds.y)
		self:rectangle(bounds)
		cairo_fill(self.cr)
	end,
	display = function(self)
		VIEWPORT_NEEDS_DISPLAY(VIEWPORT)
	end,
	destroy = function(self)
	  cairo_destroy(self.cr)
	  cairo_surface_destroy(self.cs)
	end
}
Cairo.mt.__index = Cairo.prototype

Cairo.new = function(c)
	c = c or {}
	if c.cs then c.cr = cairo_create(c.cs) end
	setmetatable(c, Cairo.mt)
	return c
end

Cairo.surface = function(rect)
	return Cairo.new{cs = cairo_quartz_surface_create(CAIRO_FORMAT_ARGB32, rect.width, rect.height), bounds = rect}
end
