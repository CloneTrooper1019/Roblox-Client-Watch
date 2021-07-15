if not plugin then
	return
end

local main = script.Parent.Parent

local getFFlagStudioEnableLightGuides = require(main.Src.Flags.getFFlagStudioEnableLightGuides)
if not getFFlagStudioEnableLightGuides() then
	return
end

local MainPlugin = require(main.Src.MainPlugin)

local mainPlugin
local listener

local function init()
	plugin.Name = main.Name
	mainPlugin = MainPlugin.new()
	mainPlugin:renderSelection()
end

local function shutdown()
	if mainPlugin then
		mainPlugin:destroy()
		mainPlugin = nil
	end
end

local function checkEnabled()
	if settings().Studio["Show Light Guides"] then
		init()
	else
		shutdown()
	end
end

plugin.Unloading:Connect(function()
	if mainPlugin then
		shutdown()
	end

	if listener then
		listener:Disconnect()
		listener = nil
	end
end)

listener = settings().Studio:GetPropertyChangedSignal("Show Light Guides"):Connect(function()
	checkEnabled()
end)

checkEnabled()
