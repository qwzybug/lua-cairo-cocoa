LifeGrid = {
  new =
    function(self, width, height)
      g = { width = width,
            height = height,
            values = {} }
      setmetatable(g, self)
      self.__index = self
      for i = 0, height-1 do
        local row = {}
        for j = 0, width-1 do row[j] = false end
        g.values[i] = row
      end
      return g
    end,
  valueAt =
    function(self, x, y)
      return self.values[x % self.height][y % self.width]
    end,
  setValueAt =
    function(self, x, y, value)
      self.values[x % self.height][y % self.width] = value
    end,
  neighbors =
    function(self, x, y)
      return {
        self:valueAt(x-1, y-1), self:valueAt(x-1, y), self:valueAt(x-1, y+1),
        self:valueAt(x, y-1),                         self:valueAt(x, y+1),
        self:valueAt(x+1, y-1), self:valueAt(x+1, y), self:valueAt(x+1, y+1)
      }
    end,
  neighborCount =
    function(self, x, y)
      local n = 0
      for _, v in pairs(self:neighbors(x,y)) do
        if v then n = n + 1 end
      end
      return n
    end,
  eachCell =
    function(self)
      local i, j, jj = 0, 0, 0
      return function()
        while i < self.height do
          while j < self.width do
            j, jj = j + 1, j
            return i, jj, self:valueAt(i, jj)
          end
          i, j = i + 1, 0
        end
        return nil
      end
    end
}

LifeGame = {
  new =
    function(self, width, height)
      g = { grid = LifeGrid:new(width, height),
            nextgrid = LifeGrid:new(width, height) }
      setmetatable(g, self)
      self.__index = self
      return g
    end,
  update =
    function(self)
      local count, newval
      for x, y, val in self.grid:eachCell() do
        count = self.grid:neighborCount(x, y)
        newval = ((self.grid:valueAt(x,y) and count == 2) or count == 3)
        self.nextgrid:setValueAt(x, y, newval)
      end
      self.grid, self.nextgrid = self.nextgrid, self.grid
    end
}

conwayGame = LifeGame:new(20, 20)
-- the r-pentomino
conwayGame.grid:setValueAt(1, 1, true)
conwayGame.grid:setValueAt(2, 1, true)
conwayGame.grid:setValueAt(2, 2, true)
conwayGame.grid:setValueAt(3, 2, true)
conwayGame.grid:setValueAt(2, 3, true)

lifeBoard = obj{View, name="lifeBoard",
	bounds = {x = 60, y = 60, width = 240, height = 240},
	subviews = {},
	cellWidth = function(self) return self.bounds.width / self.game.grid.width end,
	cellHeight = function(self) return self.bounds.height / self.game.grid.height end,
	mouseUp = function(self, evt)
		local myX = math.floor((evt.pos.x - self.bounds.x) / self:cellWidth())
		local myY = math.floor((evt.pos.y - self.bounds.y) / self:cellHeight())
		local cur = self.game.grid:valueAt(myX, myY)
		self.game.grid:setValueAt(myX, myY, not cur)
		self:draw()
	end,
	draw = function(self)
		c:rectangle(self.bounds)
		c.color = Color.black
		c:stroke()

		c.color = Color.white
		c:rectangle(self.bounds)
		c:fill()
		
		c.color = Color.black
		local cellWidth, cellHeight = self:cellWidth(), self:cellHeight()
		for x, y, val in self.game.grid:eachCell() do
			if val then
				c:rectangle{
					x = self.bounds.x + cellWidth * x,
					y = self.bounds.y + cellHeight * y,
					width = cellWidth,
					height = cellHeight
				}
				c:fill()
			end
		end
	end
}

lifeView = obj{View,
	bounds = viewport.bounds,
	name = "lifeView",
	game = conwayGame,
	board = lifeBoard,
	subviews = {lifeBoard,
				obj{Label, size=24, bounds={x=60, y=50, width=200, height=24}, subviews={},
					text="Conway's Game of Life" },
				obj{Button, name="lifeButton", title="Step", bounds={x=140, y=320, width=80, height=24}, subviews={},
					action = function(self) self.game:update(); self.board:draw() end }
				}
}
