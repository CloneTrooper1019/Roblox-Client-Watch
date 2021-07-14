--[[
	This is the Vote component for AssetPreview component.

	Necessary properties:
	Voting = table, a table contains the voting data
	AssetId = num
	OnVoteUpButtonActivated = callback, for the behavior when the  Vote Up Button is clicked.
	OnVoteDownButtonActivated = callback, for the behavior when the Vote Down Button is clicked.

	Optionlal properties:
	Size = UDim2,
	Position = UDim2,
	layoutOrder = num
]]

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local RoundButton = require(Library.Components.RoundFrame)
local RoundFrame = require(Library.Components.RoundFrame)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local Vote = Roact.PureComponent:extend("Vote")

local INLINE_PADDING = 6

local BUTTON_STATUS = {
	default = 0,
	hovered = 1,
}

function Vote:init(props)
	self.state = {
		voteUpStatus = BUTTON_STATUS.default,
		voteDownStatus = BUTTON_STATUS.default,
	}

	self.onVoteUpButtonActivated = function()
		self.props.OnVoteUpButtonActivated(self.props.AssetId, self.props.Voting)
	end

	self.onVoteDownButtonActivated = function()
		self.props.OnVoteDownButtonActivated(self.props.AssetId, self.props.Voting)
	end

	self.onVoteUpEnter = function()
		self:setState({
			voteUpStatus = BUTTON_STATUS.hovered
		})
	end

	self.onVoteUpLeave = function()
		self:setState({
			voteUpStatus = BUTTON_STATUS.default
		})
	end

	self.onVoteDownEnter = function()
		self:setState({
			voteDownStatus = BUTTON_STATUS.hovered
		})
	end

	self.onVoteDownLeave = function()
		self:setState({
			voteDownStatus = BUTTON_STATUS.default
		})
	end
end

function Vote:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state

		local position = props.Position or UDim2.new(1, 0, 1, 0)
		local size = props.Size or UDim2.new(0, 100, 0, 20)

		local voting = props.Voting
		local canVote = voting.CanVote
		local hasVoted = voting.HasVoted
		local userVote = voting.UserVote
		local upVotes = voting.UpVotes or 0
		local downVotes = voting.DownVotes or 0
		local totalVotes = 0
		local upVoteRate = 0

		local voteTheme = theme.assetPreview.vote

		local voteUpBGColor = voteTheme.button.backgroundColor
		local voteDownBGColor = voteTheme.button.backgroundColor
		local voteUpBGTransparancy = voteTheme.button.backgroundTrans
		local voteDownBGTransparancy = voteTheme.button.backgroundTrans
		local voteUpStatus = state.voteUpStatus
		local voteDownStatus = state.voteDownStatus
		if not canVote then
			voteUpBGColor = voteTheme.button.disabledColor
			voteDownBGColor = voteTheme.button.disabledColor
		else
			if voteUpStatus == BUTTON_STATUS.hovered then
				voteUpBGTransparancy = voteUpBGTransparancy + 0.3
			end
			if voteDownStatus == BUTTON_STATUS.hovered then
				voteDownBGTransparancy = voteDownBGTransparancy + 0.3
			end

			if hasVoted then
				if userVote then
					voteUpBGColor = voteTheme.voteUp.backgroundColor
				else
					voteDownBGColor = voteTheme.voteDown.backgroundColor
				end
			end

			totalVotes = upVotes + downVotes
			if totalVotes > 0 then
				upVoteRate = (upVotes / totalVotes) * 100
			end
		end

		local layoutOrder = props.LayoutOrder

		return Roact.createElement(RoundFrame, {
			Position = position,
			Size = size,

			BackgroundTransparency = voteTheme.backgroundTrans,
			BackgroundColor3 = voteTheme.background,
			BorderColor3 = voteTheme.boderColor,

			LayoutOrder = layoutOrder,
		},{
			VoteButtons = Roact.createElement("Frame", {
				Position = UDim2.new(1, -64, 0, 0),
				Size = UDim2.new(0, 64, 1, 0),

				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 0),
					PaddingLeft = UDim.new(0, 0),
					PaddingRight = UDim.new(0, INLINE_PADDING),
					PaddingTop = UDim.new(0, 0),
				}),

				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					VerticalAlignment = Enum.VerticalAlignment.Center,

					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, INLINE_PADDING),
				}),


				VoteDownButton = Roact.createElement(RoundButton, {
					Active = canVote,
					Size = UDim2.new(0, 28, 0, 28),

					BackgroundTransparency = voteDownBGTransparancy,
					BackgroundColor3 = voteDownBGColor,
					BorderColor3 = voteTheme.voteDown.borderColor,

					LayoutOrder = 1,
					AutoButtonColor = false,

					OnActivated = self.onVoteDownButtonActivated,
					OnMouseEnter = self.onVoteDownEnter,
					OnMouseLeave = self.onVoteDownLeave,
				}, {
					VoteDownImageLabel = Roact.createElement("ImageLabel", {
						Size = UDim2.new(1, 0, 1, 0),

						Image = voteTheme.images.voteDown,
						BackgroundTransparency = 1,
					})
				}),

				VoteUpButton = Roact.createElement(RoundButton, {
					Active = canVote,

					Size = UDim2.new(0, 28, 0, 28),

					BackgroundTransparency = voteUpBGTransparancy,
					BackgroundColor3 = voteUpBGColor,
					BorderColor3 = voteTheme.voteUp.borderColor,

					LayoutOrder = 2,
					AutoButtonColor = false,

					OnActivated = self.onVoteUpButtonActivated,
					OnMouseEnter = self.onVoteUpEnter,
					OnMouseLeave = self.onVoteUpLeave,
				}, {
					VoteUpImageLabel = Roact.createElement("ImageLabel", {
						Size = UDim2.new(1, 0, 1, 0),

						Image = voteTheme.images.voteUp,
						BackgroundTransparency = 1,
					})
				}),
			}),

			VoteInformations = Roact.createElement("Frame", {
				Position = UDim2.new(0, INLINE_PADDING, 0, 0),
				Size = UDim2.new(1, -64, 1, 0),

				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
				}),

				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,

					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8),
				}),

				VoteIcon = Roact.createElement("ImageLabel", {
					Size = UDim2.new(0, 17, 0, 20),
					BackgroundTransparency = 1,
					Image = voteTheme.images.thumbUp,
				}),

				VoteRatio = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, 28, 1, 0),

					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,

					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = ("%d%%"):format(upVoteRate),
					TextSize = theme.assetPreview.textSizeLarge,
					Font = theme.assetPreview.font,
					TextColor3 = voteTheme.textColor,

					LayoutOrder = 1,
				}),

				TotalVotes = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),

					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,

					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = ("%d VOTES"):format(totalVotes),
					TextSize = theme.assetPreview.textSize,
					Font = theme.assetPreview.font,
					TextColor3 = voteTheme.subTextColor,

					LayoutOrder = 2,
				}),
			}),
		})
	end)
end

return Vote