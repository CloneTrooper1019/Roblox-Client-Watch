--[[
	A set of buttons to navigate through a sequence of pages.

	Required Props:
		number PageIndex: The index of the current page
		number PageCount: The total number of pages
		callback OnPageChange: Called when the user changes the page number

	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		ContextItem Localization: A Localization ContextItem, which is provided via mapToProps.

]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Resources = require(Framework.Resources)
local LOCALIZATION_PROJECT_NAME = Resources.LOCALIZATION_PROJECT_NAME
local COMPONENT_NAME = "PageNavigation"

local Pane = require(Framework.UI.Pane)
local Button = require(Framework.UI.Button)
local Tooltip = require(Framework.UI.Tooltip)
local Image = require(Framework.UI.Image)
local TextLabel = require(Framework.UI.TextLabel)
local TextInput = require(Framework.UI.TextInput)

local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local Typecheck = Util.Typecheck

local PageNavigation = Roact.PureComponent:extend("PageNavigation")
Typecheck.wrap(PageNavigation, script)

function PageNavigation:init()
	assert(THEME_REFACTOR, "PageNavigation not supported in Theme1, please upgrade your plugin to Theme2")
	self.firstPage = function()
		self.pageChange(1)
	end
	self.nextPage = function()
		self.pageChange(self.props.PageIndex + 1)
	end
	self.lastPage = function()
		self.pageChange(self.props.PageCount)
	end
	self.prevPage = function()
		self.pageChange(self.props.PageIndex - 1)
	end
	self.textChanged = function(text)
		local index = tonumber(text) or 1
		self.pageChange(index)
	end
	self.pageChange = function(index)
		local clamped = math.clamp(index, 1, self.props.PageCount)
		if clamped ~= self.props.PageIndex then
			self.props.OnPageChange(clamped)
		end
	end
end

function PageNavigation:render()
	local props = self.props
	local style = props.Stylizer
	local pageIndex = props.PageIndex

	local localization = self.props.Localization

	local prevStyleModifier = pageIndex == 1 and StyleModifier.Disabled or nil
	local nextStyleModifier = pageIndex >= props.PageCount and StyleModifier.Disabled or nil

	return Roact.createElement(Pane, {
		Padding = style.Padding,
		AutomaticSize = Enum.AutomaticSize.XY,
		Layout = Enum.FillDirection.Horizontal,
		Spacing = style.Spacing,
	}, {
		First = Roact.createElement(Button, {
			StyleModifier = prevStyleModifier,
			Style = "RoundSubtle",
			Size = UDim2.fromOffset(style.ButtonSize, style.ButtonSize),
			LayoutOrder = 1,
			OnClick = self.firstPage,
		}, {
			Tooltip = Roact.createElement(Tooltip, {
				Text = localization:getProjectText(LOCALIZATION_PROJECT_NAME, COMPONENT_NAME, "FirstPage")
			}),
			Icon = Roact.createElement(Image, {
				Size = UDim2.fromOffset(style.IconSize, style.IconSize),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = style.IconColor,
				Image = "rbxasset://textures/DeveloperFramework/PageNavigation/button_control_start.png"
			}),
		}),
		Prev = Roact.createElement(Button, {
			StyleModifier = prevStyleModifier,
			Style = "RoundSubtle",
			Size = UDim2.fromOffset(style.ButtonSize, style.ButtonSize),
			LayoutOrder = 2,
			OnClick = self.prevPage,
		}, {
			Tooltip = Roact.createElement(Tooltip, {
				Text = localization:getProjectText(LOCALIZATION_PROJECT_NAME, COMPONENT_NAME, "PreviousPage")
			}),
			Icon = Roact.createElement(Image, {
				Size = UDim2.fromOffset(style.IconSize, style.IconSize),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = style.IconColor,
				Image = "rbxasset://textures/DeveloperFramework/PageNavigation/button_control_previous.png"
			}),
		}),
		Page = Roact.createElement(TextLabel, {
			Text = "Page",
			LayoutOrder = 3,
			AutomaticSize = Enum.AutomaticSize.XY,
		}),
		PageIndex = Roact.createElement(TextInput, {
			LayoutOrder = 4,
			Text = tostring(props.PageIndex),
			OnTextChanged = self.textChanged,
			Style = "RoundedBorder",
			Size = UDim2.new(0, style.InputWidth, 0, style.ButtonSize),
		}),
		PageCount = Roact.createElement(TextLabel, {
			LayoutOrder = 5,
			Text = localization:getProjectText(LOCALIZATION_PROJECT_NAME, COMPONENT_NAME, "PageCount", {
				count = props.PageCount
			}),
			AutomaticSize = Enum.AutomaticSize.XY,
		}),
		Next = Roact.createElement(Button, {
			StyleModifier = nextStyleModifier,
			Style = "RoundSubtle",
			Size = UDim2.fromOffset(style.ButtonSize, style.ButtonSize),
			LayoutOrder = 6,
			OnClick = self.nextPage,
		}, {
			Tooltip = Roact.createElement(Tooltip, {
				Text = localization:getProjectText(LOCALIZATION_PROJECT_NAME, COMPONENT_NAME, "NextPage")
			}),
			Icon = Roact.createElement(Image, {
				Size = UDim2.fromOffset(style.IconSize, style.IconSize),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = style.IconColor,
				Image = "rbxasset://textures/DeveloperFramework/PageNavigation/button_control_next.png"
			}),
		}),
		Last = Roact.createElement(Button, {
			StyleModifier = nextStyleModifier,
			Style = "RoundSubtle",
			Size = UDim2.fromOffset(style.ButtonSize, style.ButtonSize),
			LayoutOrder = 7,
			OnClick = self.lastPage,
		}, {
			Tooltip = Roact.createElement(Tooltip, {
				Text = localization:getProjectText(LOCALIZATION_PROJECT_NAME, COMPONENT_NAME, "LastPage")
			}),
			Icon = Roact.createElement(Image, {
				Size = UDim2.fromOffset(style.IconSize, style.IconSize),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = style.IconColor,
				Image = "rbxasset://textures/DeveloperFramework/PageNavigation/button_control_end.png"
			}),
		}),
	})
end

ContextServices.mapToProps(PageNavigation, {
	Localization = ContextServices.Localization,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
})

return PageNavigation