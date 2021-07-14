--[[
	Gets the original raw, un-calcuated UI or StudioUI style table for a given component.
]]

local Framework = script.Parent.Parent
local StudioUIFolderData = require(Framework.StudioUI.StudioUIFolderData)
local UIFolderData = require(Framework.UI.UIFolderData)

return function(componentName)
	local componentData = UIFolderData[componentName] or StudioUIFolderData[componentName]
	local result

	if componentData and componentData.style then
		result = require(componentData.style)
	end
	return result
end