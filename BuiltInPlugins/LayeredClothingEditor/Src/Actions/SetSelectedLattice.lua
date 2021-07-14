--[[
	The current lattice selected by the lattice tool
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(selectedLattice)
	return {
		selectedLattice = selectedLattice,
	}
end)