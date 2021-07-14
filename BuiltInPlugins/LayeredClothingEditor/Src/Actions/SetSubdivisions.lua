--[[
	Stores data about the lattice subdivisions for each deformer
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(subdivisions)
	return {
		subdivisions = subdivisions,
	}
end)