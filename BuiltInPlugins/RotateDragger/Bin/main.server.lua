if game:GetFastFlag("UseEngineFeature") then
	if not game:GetEngineFeature("LuaDraggers") then
		return
	end
else
	local ABTestService = game:GetService("ABTestService")
	if not settings():GetFFlag("EnableLuaDraggers") and
		ABTestService:GetVariant("ForceLuaDraggers") == "Control" then
		return
	end
end

-- Libraries
local Plugin = script.Parent.Parent
local DraggerFramework = Plugin.Packages.DraggerFramework
local Roact = require(Plugin.Packages.Roact)

-- Dragger component
local DraggerContext_PluginImpl = require(DraggerFramework.Implementation.DraggerContext_PluginImpl)
local DraggerToolComponent = require(DraggerFramework.DraggerTools.DraggerToolComponent)
local DraggerTool = require(DraggerFramework.DraggerTool)
local RotateToolImpl = require(Plugin.Src.RotateToolImpl)

local getFFlagDraggerRefactor = require(DraggerFramework.Flags.getFFlagDraggerRefactor)

local PLUGIN_NAME = "RotateDragger"
local DRAGGER_TOOL_NAME = "Rotate"
local TOOLBAR_NAME = "Home"

local pluginEnabled = false
local pluginHandle = nil
local toolButton = nil

local function openPlugin()
	if pluginHandle then
		warn("Plugin handle already exists")
		return
	end

	pluginEnabled = true
	plugin:Activate(true)

	toolButton:SetActive(true)

	if getFFlagDraggerRefactor() then
		local draggerContext = DraggerContext_PluginImpl.new(plugin, game, settings())
		pluginHandle = Roact.mount(Roact.createElement(DraggerToolComponent, {
			AnalyticsName = "Rotate",
			Mouse = plugin:GetMouse(),
			AllowDragSelect = true,
			AllowFreeformDrag = true,
			ShowSelectionDot = false,
			DraggerContext = draggerContext,
			ToolImplementation = RotateToolImpl.new(draggerContext),
		}))
	else
		pluginHandle = Roact.mount(Roact.createElement(DraggerTool, {
			AnalyticsName = "Rotate",
			Mouse = plugin:GetMouse(),
			AllowDragSelect = true,
			AllowFreeformDrag = true,
			ShowSelectionDot = false,
			ToolImplementation = RotateToolImpl.new(),
		}))
	end
end

local function closePlugin()
	pluginEnabled = false
	toolButton:SetActive(false)
	if pluginHandle then
		Roact.unmount(pluginHandle)
		pluginHandle = nil
	end
end

local function main()
	plugin.Name = PLUGIN_NAME
	local toolbar = plugin:CreateToolbar(TOOLBAR_NAME)
	toolButton = toolbar:CreateButton(
		DRAGGER_TOOL_NAME,
		"Rotate an Object",
		"",
		"Rotate"
	)

	plugin.Deactivation:connect(function()
		if pluginEnabled then
			closePlugin()
		end
	end)

	toolButton.Click:connect(function()
		if pluginEnabled then
			closePlugin()
		else
			openPlugin()
		end
	end)
end

main()