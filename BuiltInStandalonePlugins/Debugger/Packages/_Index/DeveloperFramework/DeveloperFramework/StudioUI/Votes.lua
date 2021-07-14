--[[
	Shows an icon representing votes, and a summary of the thing's votes.

	Required Props:
		Voting Voting: Table of Voting info.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Style Style: The styling for the component.
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

local UI = require(Framework.UI)
local Container = UI.Container
local Image = UI.Decoration.Image
local TextLabel = UI.Decoration.TextLabel

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Votes = Roact.PureComponent:extend("Votes")
Typecheck.wrap(Votes, script)

function Votes:render()
	local props = self.props
	local Voting = props.Voting

	local votePercentage = 0
	local total = Voting.UpVotes + Voting.DownVotes
	if total > 0 then
		votePercentage = math.floor((Voting.UpVotes / total) * 100)
	end

	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local size = prioritize(props.Size, style.Size)

	return Roact.createElement(Container, {
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Size = size
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Icon = Roact.createElement(Image, {
			LayoutOrder = 1,
			Style = style.Icon,
		}),
		Text = Roact.createElement(TextLabel, {
			LayoutOrder = 2,
			FitWidth = true,
			Text = string.format("%d%%", votePercentage),
			Style = style.Text,
		})
	})
end

ContextServices.mapToProps(Votes, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return Votes