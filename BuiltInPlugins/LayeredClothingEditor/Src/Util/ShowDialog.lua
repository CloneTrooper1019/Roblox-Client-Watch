local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Framework = require(Plugin.Packages.Framework)

local PluginTheme = require(Plugin.Src.Resources.PluginTheme)

local DebugFlags = require(Plugin.Src.Util.DebugFlags)
local TestHelper = require(Plugin.Src.Util.TestHelper)

local Cryo = require(Plugin.Packages.Cryo)

local ContextServices = Framework.ContextServices

local function showDialog(plugin, localization, dialog, props)
	local handle = nil
	local function closeDialog(props)
		if handle then
			Roact.unmount(handle)
		end
		if props.OnClose then
			props.OnClose()
		end
	end

	local dialogElement = ContextServices.provide({
		localization,
		PluginTheme.makePluginTheme(),
		plugin
	},{
		Roact.createElement(dialog, Cryo.Dictionary.join(props,{
			OnClose = function()
				closeDialog(props)
			end
		}))
	})
	local parent = nil
	local isRunningTests = DebugFlags.RunTests() or DebugFlags.RunRhodiumTests()
	if isRunningTests then
		parent = TestHelper.getTempScreenGui()
	end
	handle = Roact.mount(dialogElement,parent)

	return closeDialog
end

return showDialog