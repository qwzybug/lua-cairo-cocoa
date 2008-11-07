-- have to mess around with the lua path later...
--require"grid"


Grid = {}
Grid.mt = {}
Grid.prototype = {
	rows = 10, cols = 10,
	fillCell = function(self, x, y) fillCell(self.grid, x, y) end,
	clear = function(self) clearGrid(self.grid) end,
	drawGrid = function(self, theGrid)
		self:clear()
		for x, y, val in theGrid:eachCell() do
			if val then self:fillCell(x, y) end
		end
	end
}

Grid.new = function(g)
	g = g or {}
	setmetatable(g, Grid.mt);
	return g;
end
Grid.mt.__index = Grid.prototype

myGrid = Grid.new{grid = grid}


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
    end,
  print =
    function(self)
      local row, reps = {}, {[true] = "*", [false] = "-"}
      for x, y, val in self.grid:eachCell() do
        if y == 0 then print(table.concat(row)); row = {} end
        table.insert(row, reps[val])
      end
    end,
  draw =
    function(self, theGrid)
	  for x, y, val in self.grid:eachCell() do
		if val then theGrid:fillCell(x, y) end
	  end
    end
}


conwayGame = LifeGame:new(10, 10)
-- the r-pentomino
conwayGame.grid:setValueAt(1, 1, true)
conwayGame.grid:setValueAt(2, 1, true)
conwayGame.grid:setValueAt(2, 2, true)
conwayGame.grid:setValueAt(3, 2, true)
conwayGame.grid:setValueAt(2, 3, true)

conwayStep = function()
	conwayGame:update()
	myGrid:drawGrid(conwayGame.grid)
end
