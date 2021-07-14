--[[
	Show the Favorite count for something, and whether the user has favorited it.
	The icon can be clicked to toggle favorite status.

	Required Props:
		ContextItem Localization: A Localization ContextItem, which is provided via mapToProps.
		number Count: the number of favorites this thing has.
		boolean IsFavorited: does the current user have this thing favorited
		callback OnClick: Called when clicking the icon.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number LayoutOrder: LayoutOrder of the component.
		UDim2 Position: The position of this component.
		UDim2 Size: The size of this component.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local prioritize = Util.prioritize

local Resources = require(Framework.Resources)
local LOCALIZATION_PROJECT_NAME = Resources.LOCALIZATION_PROJECT_NAME

local UI = require(Framework.UI)
local Container = UI.Container
local Button = UI.Button
local HoverArea = UI.HoverArea
local TextLabel = UI.Decoration.TextLabel

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local COMPONENT_NAME = "Favorites"

local Favorites = Roact.PureComponent:extend(COMPONENT_NAME)
Typecheck.wrap(Favorites, script)

--[[
	Counts >= 10000 will be displayed as thousands with a localized thousands symbol
]]
function Favorites:formatCount(count)
	if count < 10000 then
		-- TODO DEVTOOLS-4351: Localized formatting for numbers in this range
		return tostring(count)
	else
		return self.props.Localization:getProjectText(LOCALIZATION_PROJECT_NAME, COMPONENT_NAME, "FlooredCountInThousands", {
			count = math.floor(count / 1000)
		})
	end
end

function Favorites:render()
	local props = self.props

	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local buttonStyle = props.IsFavorited and style.Button.Filled or style.Button.Unfilled

	local size = prioritize(props.Size, style.Size)

	return Roact.createElement(Container, {
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Size = size,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = style.ElementPadding,
		}),
		Icon = Roact.createElement(Button, {
			LayoutOrder = 1,
			Style = buttonStyle,
			OnClick = props.OnClick,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
		}, {
			Roact.createElement(HoverArea, {
				Cursor = "PointingHand",
			}),
		}),
		Text = Roact.createElement(TextLabel, {
			LayoutOrder = 2,
			FitWidth = true,
			Style = style.Text,
			Text = self:formatCount(props.Count),
		}),
	})
end

ContextServices.mapToProps(Favorites, {
	Localization = ContextServices.Localization,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return Favorites