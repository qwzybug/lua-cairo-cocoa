package.path = BASE_PATH.."/Contents/Resources/?.lua"
package.cpath = BASE_PATH.."/Contents/Frameworks/?.so"

require"luacairo"
require"prototype"

-- convenience method for table defaults
defaults = function(t, d)
  t = t or {}
  setmetatable(t, d)
  d.__index = d
  return t
end

c = Cairo.new{cr=cr, bounds={x=0, y=0, width=VIEWPORT_WIDTH, height=VIEWPORT_HEIGHT}}

mouseDown = function(x, y)
  viewport:event{name="mouseDown", pos={x=x, y=y}}
end
mouseUp = function(x, y)
  viewport:event{name="mouseUp", pos={x=x, y=y}}
end

-- GUI hierarchy

View = obj{
  subviews = {},
  bounds = {x=0, y=0, width=0, height=0},
  background = Color.white,
  draw = function(self)
    for _,v in pairs(self.subviews) do
      v:draw()
    end
  end,
  hitTest = function(self, pos)
	return		(0 < pos.x - self.bounds.x)
	        and (pos.x - self.bounds.x < self.bounds.width)
		    and (0 < pos.y - self.bounds.y)
			and (pos.y - self.bounds.y < self.bounds.height)
  end,
  addSubview = function(self, v)
    v._parent = self
	v:layout()
    table.insert(self.subviews, v)
    self:draw()
  end,
  layout = function(self)
	for _,v in pairs(self.subviews) do
	  v._parent = self
	  v:layout()
	end
  end,
  respondsTo = function(self, evt)
    return self[evt] ~= nil
  end,
  event = function(self, evt)
	if self:respondsTo(evt.name) then
	  self[evt.name](self, evt)
	else
      for _,v in pairs(self.subviews) do
        if v:hitTest(evt.pos) then v:event(evt) end
      end
    end
  end
}

Button = obj{View,
	pushed = false,
	title = "Button",
	draw = function(self)
		c:rectangle(self.bounds)
		if self.pushed then c.color = Color.red else c.color = Color.white end
		c:fill(true)
		c.color = Color.black
		c:stroke()
		c:text(self.title, {size = 16, x = self.bounds.x + 5,
		                    y = self.bounds.y + self.bounds.height/2 + 8})
	end,
	mouseDown = function(self, evt)
		self.pushed = true
		self:draw()
	end,
	mouseUp = function(self, evt)
		self:action()
		self.pushed = false
		self:draw()
	end,
	action = function(self) end
}

Label = obj{View,
  text = "",
  size = 16,
  draw = function(self)
    c:text(self.text, {size=self.size, x=self.bounds.x, y=self.bounds.y})
  end
}

viewport = obj{View,
  bounds = { x=0, y=0, width=VIEWPORT_WIDTH, height=VIEWPORT_HEIGHT },
  name = "viewport"
}
