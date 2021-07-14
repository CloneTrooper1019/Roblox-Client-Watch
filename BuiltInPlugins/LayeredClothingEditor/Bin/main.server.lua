--[[
	Layered Clothing Editor main script.
	Mounts and unmounts the Roact tree.
]]

local FFlagEnableLayeredClothingEditor = game:DefineFastFlag("EnableLayeredClothingEditor", false)
if not FFlagEnableLayeredClothingEditor then
	return
end

local Plugin = script.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local DebugFlags = require(Plugin.Src.Util.DebugFlags)

local themeRefactorFlags = require(Plugin.Packages.Framework.Util.RefactorFlags)
themeRefactorFlags.THEME_REFACTOR = true

-- we have to do this before including the rest of the modules because they might access studio code
local isRunningTests = DebugFlags.RunTests() or DebugFlags.RunRhodiumTests()
Roact.setGlobalConfig({
	propValidation = isRunningTests,
})

if isRunningTests then
	return
end

local LayeredClothingEditorPlugin = require(Plugin.Src.Components.LayeredClothingEditorPlugin)

local handle = nil

local function init()
	local mainPlugin = Roact.createElement(LayeredClothingEditorPlugin, {
		plugin = plugin,
	})

	handle = Roact.mount(mainPlugin)
end

plugin.Unloading:Connect(function()
	if handle then
		Roact.unmount(handle)
	end
end)

init()