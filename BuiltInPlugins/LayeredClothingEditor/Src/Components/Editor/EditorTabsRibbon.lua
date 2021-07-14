--[[
	Shows the Editor tabs

	Required Props:
		string ToolMode: which tool (Point/Lattice/None) is currently in use.
		callback SetToolMode: callback for when tool tab button is clicked
		table Localization: A Localization ContextItem, which is provided via mapToProps.

	Optional Props:
		number LayoutOrder: render order of component in layout
		number ZIndex: the z sorting order of the component
		boolean HasEditingCage: determines if a cage has been loaded into the editor, some tab buttons are disabled if not.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local Util = Framework.Util

local TabsRibbon = require(Plugin.Src.Components.TabsRibbon)

local Constants = require(Plugin.Src.Util.Constants)
local Typecheck = Util.Typecheck

local EditorTabsRibbon = Roact.PureComponent:extend("EditorTabsRibbon")
Typecheck.wrap(EditorTabsRibbon, script)

function EditorTabsRibbon:init()
	self.onClick = function(key)
		if self.props.SetToolMode then
			self.props.SetToolMode(key)
		end
	end
end

function EditorTabsRibbon:render()
	local props = self.props
	local layoutOrder = props.LayoutOrder
	local zIndex = props.ZIndex
	local localization = props.Localization

	local hasEditingCage = props.HasEditingCage

	return Roact.createElement(TabsRibbon, {
		Buttons = {
			{
				Key = Constants.TOOL_MODE.Lattice,
				Text = localization:getText(Constants.LOCALIZATION_KEYS.Editor, Constants.TOOL_MODE.Lattice),
				IsEnabled = hasEditingCage
			},
			{
				Key = Constants.TOOL_MODE.Point,
				Text = localization:getText(Constants.LOCALIZATION_KEYS.Editor, Constants.TOOL_MODE.Point),
				IsEnabled = hasEditingCage,
			},
			{
				Key = Constants.TOOL_MODE.Reset,
				Text = localization:getText(Constants.LOCALIZATION_KEYS.Editor, Constants.TOOL_MODE.Reset),
				IsEnabled = hasEditingCage,
			},
		},
		OnClick = self.onClick,
		SelectedKey = self.props.ToolMode,
		ZIndex = zIndex,
		LayoutOrder = layoutOrder,
	})
end

ContextServices.mapToProps(EditorTabsRibbon,{
	Localization = ContextServices.Localization,
})

return EditorTabsRibbon