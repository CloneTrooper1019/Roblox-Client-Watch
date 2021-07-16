--[[
	The CoreGuiDebugInterface class is used to attach the DeveloperInspector to the CoreGui.
]]
local Source = script.Parent.Parent

local BindableEventBridge = require(Source.Classes.BindableEventBridge)
local DebugInterface = require(Source.Classes.DebugInterface)
local CoreGui = game:GetService("CoreGui")

local CoreGuiDebugInterface = DebugInterface:extend("CoreGuiDebugInterface", function(appName: string, guiOptions)
	local bridge = BindableEventBridge.new(CoreGui)
	local interface = DebugInterface.new("CoreGui", appName, {bridge})
	if guiOptions then
		spawn(function()
			-- The children may not be available synchronously
			interface:setGuiOptions({
				rootInstance = CoreGui:WaitForChild(guiOptions.rootInstance, 10),
				pickerParent = CoreGui:WaitForChild(guiOptions.pickerParent, 10),
				rootPath = guiOptions.rootPath or {guiOptions.rootInstance}
			})
		end)
	else
		interface:setGuiOptions({
			rootInstance = CoreGui,
			pickerParent = CoreGui,
			rootPath = {}
		})
	end
	return interface
end)

return CoreGuiDebugInterface