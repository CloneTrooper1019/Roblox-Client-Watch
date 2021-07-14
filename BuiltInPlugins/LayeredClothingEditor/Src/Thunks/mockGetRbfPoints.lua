local Plugin = script.Parent.Parent.Parent

local SetPointData = require(Plugin.Src.Actions.SetPointData)
local GetSeamData = require(Plugin.Src.Thunks.GetSeamData)
local GetBounds = require(Plugin.Src.Thunks.GetBounds)

local MockRbfData = require(Plugin.Src.Resources.MockRbfData)
local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy

return function(useFullR15)
	return function(store)
		local basePointData = {}

		if useFullR15 then
			basePointData[Enum.CageType.Inner] = deepCopy(MockRbfData)
			basePointData[Enum.CageType.Outer] = deepCopy(MockRbfData)
		else
			basePointData[Enum.CageType.Inner] = { Clothing = deepCopy(MockRbfData["UpperTorso"])}
			basePointData[Enum.CageType.Outer] = { Clothing = deepCopy(MockRbfData["UpperTorso"])}
		end

		store:dispatch(SetPointData(basePointData))

		store:dispatch(GetBounds(Enum.CageType.Outer))
		store:dispatch(GetSeamData(Enum.CageType.Outer))

		store:dispatch(GetBounds(Enum.CageType.Inner))
		store:dispatch(GetSeamData(Enum.CageType.Inner))
	end
end