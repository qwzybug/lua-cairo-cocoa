
Grid = {}
Grid.mt = {}
Grid.prototype = {
	rows = 10, cols = 10,
	fillCell = function(self, x, y) fillCell(self.grid, x, y) end
}

Grid.new = function(g)
	g = g or {}
	setmetatable(g, Grid.mt);
	return g;
end
Grid.mt.__index = Grid.prototype

myGrid = Grid.new{grid = grid}

myGrid:fillCell(5, 5)
