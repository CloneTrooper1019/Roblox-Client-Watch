if not plugin then
	return
end

-- Fast flags
require(script.Parent.defineLuaFlags)


local Plugin = script.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Rodux = require(Plugin.Packages.Rodux)
local UILibrary = require(Plugin.Packages.UILibrary)

local Util = Plugin.Src.Util
local PluginTheme = require(Plugin.Src.Resources.PluginTheme)
local Constants = require(Util.Constants)

local MainReducer = require(Plugin.Src.Reducers.MainReducer)

local NetworkInterface = require(Plugin.Src.Networking.NetworkInterface)

-- localization
local TranslationDevelopmentTable = Plugin.Src.Resources.TranslationDevelopmentTable
local TranslationReferenceTable = Plugin.Src.Resources.TranslationReferenceTable
local Localization = UILibrary.Studio.Localization

local ServiceWrapper = require(Plugin.Src.Components.ServiceWrapper)

local StudioService = game:GetService("StudioService")
local ScreenSelect = require(Plugin.Src.Components.ConvertToPackageWindow.ScreenSelect)

local localization = Localization.new({
	stringResourceTable = TranslationDevelopmentTable,
	translationResourceTable = TranslationReferenceTable,
	pluginName = "ConvertToPackage",
})

local assetConfigHandle = nil
local assetConfigGui  = nil
local function makePluginGui()
	assetConfigGui = plugin:CreateQWidgetPluginGui(plugin.Name, {
		Size = Vector2.new(960, 600),
		MinSize = Vector2.new(960, 600),
		Resizable = true,
		Modal = true,
		InitialEnabled = false,
	})
	
	assetConfigGui.Name = plugin.Name
	assetConfigGui.Title = plugin.Name
	assetConfigGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	assetConfigGui:GetPropertyChangedSignal("Enabled"):connect(function()
		-- Handle if user clicked the X button to close the window
		if not assetConfigGui.Enabled then
			if assetConfigHandle then
				Roact.unmount(assetConfigHandle)
				assetConfigHandle = nil
			end
		end
	end)
end

local function onAssetConfigDestroy()
	if assetConfigHandle then
		Roact.unmount(assetConfigHandle)
		assetConfigHandle = nil
	end
	assetConfigGui.Enabled = false
end

-- assetTypeEnum Enum.AssetType, some asset like places, need to use the parameter to
--				set the assetType of the Asset, and skip the assetTypeSelection.
--				default to nil
-- instances instances, Will be used in publishing new assets. Instances are userdata,
--				we can't check the assetType using that, using AssetType instead.
-- string assetName, the initial name of the asset (used for default config).
local function openAssetConfigWindow(instances, assetName)
	if assetConfigHandle then
		return
	end

	local mainStore = Rodux.Store.new(MainReducer,
	{
		AssetConfigReducer = { instances = instances}
	},{
			Rodux.thunkMiddleware
	})

	local theme = PluginTheme.new()
	local networkInterface = NetworkInterface.new()
	local assetConfigComponent = Roact.createElement(ServiceWrapper, {
		plugin = plugin,
		store = mainStore,
		theme = theme,
		focusGui = assetConfigGui,
		networkInterface = networkInterface,
		localization = localization,
	},
	{
		Roact.createElement(ScreenSelect, {
			onClose = onAssetConfigDestroy,
			assetName = assetName,
			pluginGui = assetConfigGui,
			currentScreen = Constants.SCREENS.CONFIGURE_ASSET,
			instances = instances
		})
	})

	assetConfigHandle = Roact.mount(assetConfigComponent, assetConfigGui)
	assetConfigGui.Enabled = true
	return assetConfigHandle
end

local function main()
	plugin.Name = localization:getText("Meta", "PluginName")
	makePluginGui()
	StudioService.OnOpenConvertToPackagePlugin:connect(function(instances, name)
		-- clone instances so that user cannot edit them while validating/uploading
		local clonedInstances = {}
		for i = 1, #instances do
			pcall(function()
				clonedInstances[i] = instances[i]:Clone()
			end)
		end
		if clonedInstances == {} then
			print(localization:getText("General", "InstanceFail"))
			return
		end

		openAssetConfigWindow(clonedInstances, name)
	end)
end

main()