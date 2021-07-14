--[[
	Wrapper component for screen flow of the editor.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local ScreenFlow = require(Plugin.Src.Components.ScreenFlow)
local AssetTypeScreen = require(Plugin.Src.Components.Screens.AssetTypeScreen)
local EditorScreen = require(Plugin.Src.Components.Screens.EditorScreen)
local SelectItemScreen = require(Plugin.Src.Components.Screens.SelectItemScreen)
local GenerateScreen = require(Plugin.Src.Components.Screens.GenerateScreen)

local SelectedEditingItem = require(Plugin.Src.Components.Preview.SelectedEditingItem)

local LayeredClothingEditor = Roact.PureComponent:extend("LayeredClothingEditor")

function LayeredClothingEditor:init()
	self.screens = {
		SelectItemScreen,
		AssetTypeScreen,
		EditorScreen,
		GenerateScreen,
	}

	self.state = {
		currentScreen = 0,
	}

	self.onScreenChanged = function(index)
		self:setState({
			currentScreen = index,
		})
	end
end

function LayeredClothingEditor:render()
	return Roact.createFragment({
		SelectedEditingItem = Roact.createElement(SelectedEditingItem),
		ScreenFlow = Roact.createElement(ScreenFlow, {
			Screens = self.screens,
			OnScreenChanged = self.onScreenChanged,
		}),
	})
end

function LayeredClothingEditor:willUnmount()
	self.props.EditingItemContext:clear()
end

ContextServices.mapToProps(LayeredClothingEditor,{
	EditingItemContext = EditingItemContext,
})

return LayeredClothingEditor