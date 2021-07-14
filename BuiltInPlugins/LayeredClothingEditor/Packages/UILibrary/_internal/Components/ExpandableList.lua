--[[
	A generic expandable list interface which can accept any kind of components. Intended to be a lightweight control
	where it will toggle visibility of a frame which contains content that user will pass in

	Required Props:
		table TopLevelItem = Property which takes in table of Roact elements to display top level button.
			Will always be displayed and entire element(s) will be clickable to toggle dropdown visibility
		table Content = Property which takes in table of Roact elements to display in dropdown area.

		LayoutOrder = props.LayoutOrder (Required, passed through)
		Position = props.Position (Required, passed through)
		AnchorPoint = props.AnchorPoint (Required, passed through)

		function OnExpandedStateChanged() - Invoked whenever the ExpandableList is opened/closed
		bool IsExpanded - Whether the ExpandableList is expanded or not
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local join = require(Library.join)

local createFitToContent = require(Library.Components.createFitToContent)

local ExpandableList = Roact.PureComponent:extend("ExpandableList")

local ContentFit = createFitToContent("Frame", "UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 0),
})

local TopLevelContentFit = createFitToContent("ImageButton", "UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 0),
	FillDirection = Enum.FillDirection.Horizontal,
})

function ExpandableList:init()
	self.state = {
		isButtonHovered = false,
	}
	self.buttonRef = Roact.createRef()

	self.toggleList = function()
		self.props.OnExpandedStateChanged()
	end

	self.onMouseEnter = function()
		self:setState({
			isButtonHovered = true,
		})
	end

	self.onMouseLeave = function()
		self:setState({
			isButtonHovered = false,
		})
	end
end


function ExpandableList:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state

		local topLevelItem = props.TopLevelItem
		local content = props.Content

		assert(topLevelItem ~= nil and type(topLevelItem) == "table",
			"ExpandableList requires a TopLevelItem table.")
		assert(content ~= nil and type(content) == "table",
		   "ExpandableList requires Content table.")

		return Roact.createElement(ContentFit, {
				BackgroundTransparency = 1,
				LayoutOrder = props.LayoutOrder or 0,
				AnchorPoint = props.AnchorPoint or Vector2.new(0,0),
				BorderSizePixel = 0,
				Position = props.Position,
			}, {
				TopLevelItem = Roact.createElement(TopLevelContentFit, {
					LayoutOrder = 0,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Image = "",
					
					[Roact.Ref] = self.buttonRef,
					[Roact.Event.Activated] = self.toggleList,
					[Roact.Event.MouseEnter] = self.onMouseEnter,
					[Roact.Event.MouseLeave] = self.onMouseLeave,
				}, topLevelItem),

				ExpandableFrame = Roact.createElement(ContentFit, {
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Visible = props.IsExpanded,
				}, content),
		})
	end)
end

return ExpandableList
