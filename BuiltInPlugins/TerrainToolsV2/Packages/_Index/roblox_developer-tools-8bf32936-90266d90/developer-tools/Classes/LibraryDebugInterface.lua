--[[
	The LibraryDebugInterface class is used to attach the DeveloperInspector to a library being
	developed inside Studio in the ReplicatedStorage service.
]]
local Source = script.Parent.Parent

local BindableEventBridge = require(Source.Classes.BindableEventBridge)
local DebugInterface = require(Source.Classes.DebugInterface)

local LibraryDebuggerInterface = DebugInterface:extend("LibraryDebuggerInterface", function(libraryName: string, guiOptions)
	local bridge = BindableEventBridge.new(game:GetService("CoreGui"))
	local interface = DebugInterface.new("Library", libraryName, {bridge})
	interface:setGuiOptions(guiOptions or {
		rootInstance = game:GetService("ReplicatedStorage")
	})
	return interface
end)

return LibraryDebuggerInterface