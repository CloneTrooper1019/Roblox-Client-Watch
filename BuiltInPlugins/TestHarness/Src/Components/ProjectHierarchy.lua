-- TODO: RIDE-3499 ProjectHierarchy should display discovered tests
local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Framework = require(Plugin.Packages.Framework)

local ContextServices = Framework.ContextServices
local Stylizer = Framework.Style.Stylizer

local UI = Framework.UI
local TreeView = UI.TreeView

local GetTests = require(Plugin.Src.Thunks.GetTests)
local ExpandTest = require(Plugin.Src.Actions.ExpandTest)
local CollapseTest = require(Plugin.Src.Actions.CollapseTest)

local Components = Plugin.Src.Components
local HierarchyRow = require(Components.Layout.HierarchyRow)

local ProjectHierarchy = Roact.PureComponent:extend("ProjectHierarchy")

function ProjectHierarchy:init()
	self.renderRow = function(row)
		local expansion = self.props.Expanded
		local item = row.item
		local isExpanded = expansion[item]
		local hasChildren = item.Children and #item.Children > 0
		local indent = row.depth * 10

		local toggleExpansion = function()
			local testID = ""
			if isExpanded then
				self.props.dispatchCollapseTest(testID)
			else
				self.props.dispatchExpandTest(testID)
			end
		end

		return Roact.createElement(HierarchyRow, {
			Text = item.Name or "",
			LayoutOrder = row.index,
			HasChildren = hasChildren,
			Expanded = isExpanded,
			Indent = indent,
			OnClick = toggleExpansion,
		})
	end
end

function ProjectHierarchy:didMount()
	-- TODO: RIDE-3497 TestHarness should discover tests in the datamodel
	self.props.dispatchGetTests(Plugin)
end

-- TODO: RIDE-3497 construct hierarchy from a list of testIDs
local function getRootItems(displayedTests)
	local rootItems = {}

	return rootItems
end

local function getChildren(item)
	local children = {}

	return children
end

function ProjectHierarchy:render()
	-- TODO: RIDE-3504 Tests can be selected to run from a larger set
	-- TODO: RIDE-3501. Be able to hide tests from hierarchy
	local displayed = self.props.Displayed
	local expansion = self.props.Expanded

	return Roact.createElement(TreeView, {
		Size = UDim2.new(0, 240, 1, 0),
		Expansion = expansion,
		RootItems = getRootItems(displayed),
		RenderRow = self.renderRow,
		GetChildren = getChildren
	})
end

ContextServices.mapToProps(ProjectHierarchy, {
	Stylizer = Stylizer,
})

return RoactRodux.connect(
	function(state, props)
		return {
			TestInstances = state.TestCache.TestInstances,
			Expanded = state.TestCache.Expanded,
			Displayed = state.TestCache.Displayed,
		}
	end,
	function(dispatch)
		return {
			dispatchGetTests = function(target)
				dispatch(GetTests(target))
			end,
			dispatchExpandTest = function(testID)
				dispatch(ExpandTest(testID))
			end,
			dispatchCollapseTest = function(testID)
				dispatch(CollapseTest(testID))
			end,
		}
	end
)(ProjectHierarchy)
