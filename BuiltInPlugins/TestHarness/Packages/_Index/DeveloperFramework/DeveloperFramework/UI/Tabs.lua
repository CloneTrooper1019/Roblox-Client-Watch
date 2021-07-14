--[[
	A horizontal row of tabs with one always selected.

	Required Props:
		callback OnTabSelected: Callback for when user clicks a tab
		table Tabs: The list of tabs
		table SelectedTab: The currently selected tab

	Optional Props:
		table TabComponent: The tab component to render each tab (default = SimpleTab)
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
]]
local Framework = script.Parent.Parent
local TabsTypes = require(script.types)
local ContextServices = require(Framework.ContextServices)
local Roact = require(Framework.Parent.Roact)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck

local Dash = require(Framework.packages.Dash)
local map = Dash.map

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Pane = require(Framework.UI.Pane)
local SimpleTab = require(Framework.UI.SimpleTab)

local Tabs = Roact.PureComponent:extend("Tabs")
Typecheck.wrap(Tabs, script)

function Tabs:init()
	assert(THEME_REFACTOR, "Tabs not supported in Theme1, please upgrade your plugin to Theme2")
end

function Tabs:render()
	local props: TabsTypes.ConnectedProps = self.props
	local tabComponent = props.TabComponent or SimpleTab
	local tabs = map(props.Tabs, function(tab: TabsTypes.Tab, index: number)
		return Roact.createElement(tabComponent, {
			Tab = tab,
			Index = index,
			Disabled = tab.Disabled,
			Selected = tab == props.SelectedTab,
			OnTabSelected = props.OnTabSelected,
		})
	end)

	return Roact.createElement(Pane, {
		AutomaticSize = Enum.AutomaticSize.XY,
		Layout = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, tabs)
end

ContextServices.mapToProps(Tabs, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return Tabs
