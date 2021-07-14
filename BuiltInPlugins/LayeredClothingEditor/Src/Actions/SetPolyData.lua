--[[
	Array of vertex indices representing a triangular face. Every consecutive group of 3
	entries in the array is a separate face.
]]

local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Action = Framework.Util.Action

return Action(script.Name, function(polyData)
	return {
		polyData = polyData,
	}
end)