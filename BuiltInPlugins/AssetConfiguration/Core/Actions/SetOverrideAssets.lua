local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Util = require(Libs.Framework.Util)
local Action = Util.Action

return Action(script.Name, function(resultsArray)
	assert(typeof(resultsArray) == "table", "SetOverrideAssets resultsArray must be a table")
	return {
		resultsArray = resultsArray,
	}
end)