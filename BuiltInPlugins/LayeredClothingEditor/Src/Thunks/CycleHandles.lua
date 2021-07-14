local draggerTypes = {
	Enum.RibbonTool.Select,
	Enum.RibbonTool.Move,
	Enum.RibbonTool.Scale,
	Enum.RibbonTool.Rotate,
}

local draggerTypeMap = {}
for index, draggerTypeEnum in ipairs(draggerTypes) do
	draggerTypeMap[draggerTypeEnum] = index
end

local Plugin = script.Parent.Parent.Parent
local SetDraggerType = require(Plugin.Src.Actions.SetDraggerType)

return function()
	return function(store)
		local state = store:getState()
		local draggerType = state.status.draggerType

		local index = draggerTypeMap[draggerType]
		index = (index % #draggerTypes) + 1
		draggerType = draggerTypes[index]

		store:dispatch(SetDraggerType(draggerType))
	end
end