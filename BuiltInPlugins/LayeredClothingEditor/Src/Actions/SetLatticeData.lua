--[[
	For lattice tool: A collection of cells in the lattice and various data like what points are affected.
	A cell is a 3D rectangular section of the lattice defined by 8 corner control points.

	Format:
	{
		[deformer] = {
			rbfPointsInCell = rbf points grouped together by cells,
			controlPointToCellMap = a map the provides the rbf points that a control point affects,
			lattice = 3D grid of positions in lattice,
		}
	}
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(latticeData)
	return {
		latticeData = latticeData,
	}
end)