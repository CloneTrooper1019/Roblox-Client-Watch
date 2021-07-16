--[[
	Encapsulates the VoteBar summary, shows a count of VoteBar and allows up or down voting.

	Required Props:
		ContextItem Localization: A Localization ContextItem, which is provided via mapToProps.
		Voting Voting: Table of Voting info.
		number AssetId: Asset ID being voted on.
		callback OnVoteUp: called when the upvote button is clicked.
		callback OnVoteDown: called when the downvote button is clicked.

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
local Immutable = Util.Immutable
local Typecheck = Util.Typecheck
local prioritize = Util.prioritize
local LayoutOrderIterator = Util.LayoutOrderIterator
local StyleModifier = Util.StyleModifier

local Resources = require(Framework.Resources)
local LOCALIZATION_PROJECT_NAME = Resources.LOCALIZATION_PROJECT_NAME

local UI = require(Framework.UI)
local Container = UI.Container
local Button = UI.Button
local HoverArea = UI.HoverArea
local TextLabel = UI.Decoration.TextLabel

local Votes = require(script.Parent.Votes)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local COMPONENT_NAME = "VoteBar"

local VoteBar = Roact.PureComponent:extend(COMPONENT_NAME)
Typecheck.wrap(VoteBar, script)

function VoteBar:render()

	local props = self.props

	local canVote = props.Voting.CanVote

	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local size = prioritize(props.Size, style.Size)

	local layoutOrderIterator = LayoutOrderIterator.new()

	local function voteButton(name, isUpVote)
		local buttonStyle = canVote and style.Buttons[name].CanVote or style.Buttons[name]

		local styleModifier

		if canVote then
			local userVote = self.props.Voting.UserVote

			if userVote == true and isUpVote or userVote == false and not isUpVote then
				styleModifier = StyleModifier.Selected
			end
		else
			styleModifier = StyleModifier.Disabled
		end

		return {
			[name] = Roact.createElement(Button, {
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				Style = buttonStyle,
				StyleModifier = styleModifier,
				OnClick = function(...)
					if canVote then
						return props["On" .. name](self.props.AssetId, self.props.Voting)
					end

					return
				end,
				Size = buttonStyle.Size,
			}, {
				canVote and Roact.createElement(HoverArea, {
					Cursor = "PointingHand",
				}),
			})
		}
	end

	local leftWidthScale = 0.6
	local votesWidth = 65

	return Roact.createElement(Container, {
		Background = style.Background,
		BackgroundStyle = style.BackgroundStyle,
		Padding = style.Padding,
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Size = size
	}, {
		Left = Roact.createElement(Container, {
			Size = UDim2.new(leftWidthScale, 0, 1, 0),
		}, {
			Layout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Votes = Roact.createElement(Votes, {
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				Size = UDim2.new(0, votesWidth, 1, 0),
				Style = style.Votes,
				Voting = props.Voting,
			}),
			VoteCount = Roact.createElement(TextLabel, {
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				Size = UDim2.new(1, -votesWidth, 1, 0),
				Style = style.VoteCount,
				Text = self.props.Localization:getProjectText(LOCALIZATION_PROJECT_NAME, COMPONENT_NAME, "VoteCount", {
					count = props.Voting.UpVotes + props.Voting.DownVotes
				}),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd
			}),
		}),

		Right = Roact.createElement(Container, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(1 - leftWidthScale, 0, 1, 0),
		}, Immutable.JoinDictionaries(
			{
				Layout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 5),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			},
			voteButton("VoteDown", false),
			voteButton("VoteUp", true)
		))
	})
end

ContextServices.mapToProps(VoteBar, {
	Localization = ContextServices.Localization,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return VoteBar