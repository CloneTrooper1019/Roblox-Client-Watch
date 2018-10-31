--[[
	Clickable checkbox, from a CheckBoxSet.

	Props:
		string Id = Unique identifier of this CheckBox
		string Title = Text to display on this CheckBox
		bool Selected = Whether to display this CheckBox as selected
		bool Enabled = Whether this CheckBox accepts input
]]

local BACKGROUND_IMAGE = "rbxasset://textures/CollisionGroupsEditor/unchecked.png"
local SELECTED_IMAGE = "rbxasset://textures/CollisionGroupsEditor/checked-bluebg.png"

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)

local CheckBox = Roact.PureComponent:extend("CheckBox")

function CheckBox:mouseHoverChanged(hovering)
	--TODO: Set mouse to hand icon?
end

function CheckBox:render()
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, Constants.CHECKBOX_SIZE),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Background = Roact.createElement("ImageButton", {
				Size = UDim2.new(0, Constants.CHECKBOX_SIZE, 0, Constants.CHECKBOX_SIZE),
				BackgroundTransparency = 1,
				ImageTransparency = self.props.Enabled and 0 or 0.8,
				Image = BACKGROUND_IMAGE,
				ImageColor3 = theme.checkBox.background,
				LayoutOrder = self.props.LayoutOrder or 1,

				[Roact.Event.MouseEnter] = function()
					if self.props.Enabled then
						self:mouseHoverChanged(true)
					end
				end,

				[Roact.Event.MouseLeave] = function()
					if self.props.Enabled then
						self:mouseHoverChanged(false)
					end
				end,

				-- Tell the CheckBoxSet that this was selected
				[Roact.Event.Activated] = function()
					if self.props.Enabled then
						self.props.OnClicked()
					end
				end,
			}, {
				Selection = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Visible = self.props.Enabled and self.props.Selected,
					Image = SELECTED_IMAGE,
				}),

				TitleLabel = Roact.createElement("TextButton", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 250, 1, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(1, 10, 0.5, 0),

					TextColor3 = theme.checkBox.title,
					Font = Enum.Font.SourceSans,
					TextSize = 22,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTransparency = self.props.Enabled and 0 or 0.5,
					Text = self.props.Title or self.props.Id,

					[Roact.Event.Activated] = function()
						if self.props.Enabled then
							self.props.OnClicked()
						end
					end,
				}),
			}),
		})
	end)
end

return CheckBox