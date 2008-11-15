package.path = BASE_PATH.."/Contents/Resources/?.lua"
package.cpath = BASE_PATH.."/Contents/Frameworks/?.so"

require"luacairo"
require"prototype"

-- the controller should set VIEWPORT_WIDTH and VIEWPORT_HEIGHT before executing this file
cairo = Cairo.surface({x=0, y=0, width=VIEWPORT_WIDTH, height=VIEWPORT_HEIGHT})
cgc = cairo_quartz_surface_get_cg_context(cairo.cs)
-- the controller should also register a SET_CAIRO_CONTEXT function
-- to provide the viewport object with our CGContext
SET_CAIRO_CONTEXT(VIEWPORT, cgc)

mouseDown = function(x, y)
  viewport:event{name="mouseDown", pos={x=x, y=y}}
end
mouseUp = function(x, y)
  viewport:event{name="mouseUp", pos={x=x, y=y}}
end
mouseDragged = function(x, y)
  viewport:event{name="mouseDragged", pos={x=x, y=y}}
end

-- reverse iteration

rpairs = function(t)
  local i = table.getn(t)
  return function()
    i = i-1
    if i >= 0 then
      return t[i+1]
    else
      return nil
    end
  end
end

-- GUI hierarchy

View = obj{
  _subviews = {},
  name = "View",
  bounds = {x=0, y=0, width=0, height=0},
  frame = {x=0, y=0, width=0, height=0},
  draw = function(self) end,
  drawSubviews = function(self)
    for v in rpairs(self._subviews) do
      v.context:erase()
      v:draw()
      v:drawSubviews()
      self.context:paintSurface(v.context, v.bounds)
    end
  end,
  hitTest = function(self, pos)
    return    (0 < pos.x - self.bounds.x)
          and (pos.x - self.bounds.x < self.bounds.width)
          and (0 < pos.y - self.bounds.y)
          and (pos.y - self.bounds.y < self.bounds.height)
  end,
  addSubview = function(self, v)
    v._parent = self
    v:layout()
    table.insert(self._subviews, v)
    self:draw()
    self:drawSubviews()
  end,
  removeSubview = function(self, v)
    for k, sv in pairs(self._subviews) do
      if v == sv then
        table.remove(self._subviews, k)
        v.context:destroy()
        v.context = nil
        break
      end
      self:draw()
      self:drawSubviews()
    end
  end,
  layout = function(self)
    self.frame = {x=0, y=0, width=self.bounds.width, height=self.bounds.height}
    self.context = Cairo.surface(self.frame)
    for _,v in pairs(self._subviews) do
      v._parent = self
      v:layout()
    end
  end,
  respondsTo = function(self, evt)
    -- events shouldn't be inherited through parents
    return rawget(self, evt) or lookupProto(self, evt)
  end,
  event = function(self, evt)
    local handled = false
    local pos = {x=evt.pos.x - self.bounds.x, y=evt.pos.y - self.bounds.y}
    for _,v in pairs(self._subviews) do
      if v:hitTest(pos) then
        handled = v:event({name=evt.name, pos=pos})
      end
      if handled then break end
    end
    if not handled and self:respondsTo(evt.name) then
      self[evt.name](self, evt)
      handled = true
    end
    return handled
  end
}

Label = obj{View, name="Label",
  size = 16,
  draw = function(self)
    self.context:text(self.title, {size=self.size, x=0, y=self.size})
  end
}

Button = obj{View, name="Button",
  pushed = false,
  title = "Button",
  size = 16,
  background = {r=1, g=1, b=1, a=1},
  draw = function(self)
    self.context:roundRect(self.frame)
    self.context.color = Color.fade(Color.gray(0.5), 0.5)
    self.context:stroke(true)
    if self.pushed then
      self.context.color = self.background
    else
      self.context.color = Color.fade(self.background, 0.7)
    end
    self.context:fill()
    if self.title ~= "" then
      self.context:text(self.title, {size = self.size, x = 5,
                y = self.bounds.height/2 + self.size/2, color=Color.black})
    end
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

Window = obj{View,
  dragging = false,
  title = "Window", name="Window",
  draw = function(self)
    self.context:rectangle{x=0, y=0, width=self.bounds.width, height=self.bounds.height}
    self.context.color = Color.fade(Color.gray(0.95), 0.95)
    self.context:fill(true)
    self.context.color = Color.fade(Color.gray(0.75), 0.75)
    self.context:stroke()
  end,
  mouseDown = function(self, evt)
    self.mouseDownPoint = {x = evt.pos.x - self.bounds.x,
                           y = evt.pos.y - self.bounds.y}
    self.dragging = true
  end,
  mouseDragged = function(self, evt)
    if self.dragging then
      self.bounds.x = evt.pos.x - self.mouseDownPoint.x
      self.bounds.y = evt.pos.y - self.mouseDownPoint.y
    end
  end,
  mouseUp = function(self, evt) self.dragging = false end,
  _subviews = {
    obj{Button, title="", name="Close Button", background = Color.fade(Color.red, 0.7),
        bounds={x=4, y=4, width=16, height=16},
        action = function(self) self._parent:close() end
    },
    obj{Button, title="i", size=12, background=Color.fade(Color.blue, 0.7),
       bounds={x=24, y=4, height=16, width=16},
       action=function(self)
         viewport:addSubview(
            obj{Inspector,
                object=self._parent, title="Inspector: "..self._parent.title,
                bounds={x=50, y=50, width=200, height=200}})
       end
    },
    obj{Label, name="Label", bounds = {x=44, y=2, width=100, height=20}}
  },
  layout = function(self)
    View.layout(self)
    self.contentView = self.contentView or obj{View}
    self.contentView.bounds = {x=1, y=25, width=self.bounds.width-2, height=self.bounds.height-26}
    self:addSubview(obj{self.contentView})
  end,
  close = function(self)
    if self._parent then
      self._parent:removeSubview(self)
    end
  end
}

Inspector = obj{Window, title="Inspector",
  contentView = obj{View,
    layout = function(self)
      View.layout(self)
      local i = 0
      for k,v in pairs(self.object) do
        self:addSubview(
          obj{Label, size=10, title=k,
              bounds={x=4, y=16*i, height=16, width=self.bounds.width/2}})
        if type(v) == 'table' then
          self:addSubview(
            obj{Button, title=type(v), size=10,
                bounds = {x=self.bounds.width/2, y=16*i, height=15, width=self.bounds.width/2 - 4},
                action = function(self)
                  viewport:addSubview(obj{Inspector, object=v, title=k,
                    bounds={x=50, y=50, width=200, height=200}})
                end
            })
        else
          self:addSubview(
            obj{Label, size=10, title=tostring(v),
                bounds={x=self.bounds.width/2, y=16*i, height=16, width=self.bounds.width/2}})
        end
        i = i+1
      end
    end
  }
}

viewport = obj{View,
  bounds = { x=0, y=0, width=VIEWPORT_WIDTH, height=VIEWPORT_HEIGHT },
  context = cairo,
  draw = function(self) cairo:clear(Color.white) end,
  event = function(self, evt) self._proto.event(self,evt); self:draw(); self:drawSubviews() end,
  drawSubviews = function(self) self._proto.drawSubviews(self); cairo:display() end
}

subviewGraph = function(v)
  local subviewStrings = {}
  if v._subviews then
    for _,sv in ipairs(v._subviews) do
      table.insert(subviewStrings, subviewGraph(sv))
    end
  end
  return string.format("%s : {%s}", v.name, table.concat(subviewStrings, ", "))
end
