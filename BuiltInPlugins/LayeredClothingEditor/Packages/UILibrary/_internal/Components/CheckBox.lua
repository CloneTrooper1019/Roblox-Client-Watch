--[[
	Clickable checkbox, from a CheckBoxSet.

	Props:
		string Id = Unique identifier of this CheckBox
		string Title = Text to display on this CheckBox
		bool Selected = Whether to display this CheckBox as selected
		bool Enabled = Whether this CheckBox accepts input
		int Height = How big the CheckBox should be
		int TextSize = How big the CheckBox's text should be
		func OnActivated = What happens when the CheckBox is clicked
		int titlePadding = How many pixels to the right of the icon the title is put
	Optional:
		Frame link = a frame for a link to an external webpage
]]

local TextService = game:GetService("TextService")
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)
local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local CheckBox = Roact.PureComponent:extend("CheckBox")

function CheckBox:init()
	self.onActivated = function()
		if self.props.Enabled then
			self.props.OnActivated()
		end
	end
end

function CheckBox:render()
	return withTheme(function(theme)
		local props = self.props

		local title = props.Title
		local height = props.Height
		local enabled = props.Enabled
		local layoutOrder = props.LayoutOrder
		local selected = props.Selected
		local textSize = props.TextSize
		local titlePadding = props.TitlePadding or 5
		local link = FFlagLuobuDevPublishLua and props.Link or nil

		local titleSize = TextService:GetTextSize(
			title,
			textSize,
			theme.checkBox.font,
			Vector2.new()
		)
		local titleWidth = titleSize.X

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = layoutOrder or 1,
		}, {
			Background = Roact.createElement("ImageButton", {
				Size = UDim2.new(0, height, 0, height),
				BackgroundTransparency = 1,
				ImageTransparency = enabled and 0 or 0.4,
				Image = theme.checkBox.backgroundImage,
				ImageColor3 = theme.checkBox.backgroundColor,

				[Roact.Event.Activated] = self.onActivated,
			}, {
				Selection = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Visible = enabled and selected,
					Image = theme.checkBox.selectedImage,
				}),

				TitleLabel = Roact.createElement("TextButton", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, titleWidth, 1, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(1, titlePadding, 0.5, 0),

					TextColor3 = theme.checkBox.titleColor,
					Font = theme.checkBox.font,
					TextSize = textSize,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextTransparency = enabled and 0 or 0.5,
					Text = title,

					[Roact.Event.Activated] = self.onActivated,
				}),

				Link = link,
			}),
		})
	end)
end

return CheckBox