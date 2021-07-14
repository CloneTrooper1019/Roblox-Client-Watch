--[[
	Shows the Preview Panel's tabs

	Required Props:
		callback SelectPreviewTab: function provided via dispatch to set the preview tab
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		string SelectedTab: the preview tab selection (this is an entry from PreviewConstants.TABS_KEYS)

	Optional Props:
		number LayoutOrder: render order of component in layout
		number ZIndex: the z sorting order of the component
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		table EditingItemContext: An EditingItemContext, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local Util = Framework.Util
local Typecheck = Util.Typecheck

local TabsRibbon = require(Plugin.Src.Components.TabsRibbon)

local Constants = require(Plugin.Src.Util.Constants)
local PreviewConstantsInterface = require(Plugin.Src.Util.PreviewConstantsInterface)
local getActivePreviewTabs = require(Plugin.Src.Util.getActivePreviewTabs)

local SelectPreviewTab = require(Plugin.Src.Actions.SelectPreviewTab)

local PreviewTabsRibbon = Roact.PureComponent:extend("PreviewTabsRibbon")
Typecheck.wrap(PreviewTabsRibbon, script)

local function isTabActive(tabKey, editingItem)
	local activeTabs = getActivePreviewTabs(editingItem)
	return activeTabs[tabKey] ~= nil
end

function PreviewTabsRibbon:init()
	self.onClick = function(newTabKey)
		local props = self.props
		local selectedTab = props.SelectedTab
		local editingItem = props.EditingItemContext:getItem()

		if newTabKey == selectedTab or not isTabActive(newTabKey, editingItem) then
			return
		end
		self.props.SelectPreviewTab(newTabKey)
	end
end

function PreviewTabsRibbon:render()
	local props = self.props
	local layoutOrder = props.LayoutOrder
	local zIndex = props.ZIndex
	local localization = props.Localization
	local selectedTab = props.SelectedTab
	local editingItem = props.EditingItemContext:getItem()
	local theme = props.Stylizer

	local buttons = {}
	local tabsToDisplay = PreviewConstantsInterface.getTabs()
	for tabKey, tabInfo in pairs(tabsToDisplay) do
		buttons[tabInfo.LayoutOrder] = {
			Key = tabKey,
			Text = localization:getText(Constants.LOCALIZATION_KEYS.Preview, tabInfo.LocalizationKey),
			IsEnabled = isTabActive(tabKey, editingItem),
			Image = theme.Icons[tabKey],
		}
	end

	return Roact.createElement(TabsRibbon, {
		Buttons = buttons,
		OnClick = self.onClick,
		SelectedKey = selectedTab,
		ZIndex = zIndex,
		LayoutOrder = layoutOrder,
	})
end

ContextServices.mapToProps(PreviewTabsRibbon,{
	Localization = ContextServices.Localization,
	Stylizer = ContextServices.Stylizer,
	EditingItemContext = EditingItemContext,
})

local function mapStateToProps(state, props)
	local previewStatus = state.previewStatus

	return {
		SelectedTab = previewStatus.selectedTab,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SelectPreviewTab = function(tab)
			dispatch(SelectPreviewTab(tab))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(PreviewTabsRibbon)