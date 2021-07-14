--[[
	A component used for a link text with an animated search icon,
	that appears when the user hovers over the link text.

	Necessary Properties:
		Position = UDim2, the positon of this component.
		AnchorPoint = Vector2, the centering of the component relative to its parent.

		Text = string, the Creator name to be shown in the text label.
		OnClick = callback, A callback for when the link is clicked.

	Optional Properties:
		number TweenTime = The time in seconds to play the hover animation.
]]

local TweenService = game:GetService("TweenService")
local DEFAULT_TWEEN_TIME = 0.2

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local GetTextSize = require(Library.Utils.GetTextSize)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local SearchLinkText = Roact.PureComponent:extend("SearchLinkText")

function SearchLinkText:init(props)
	assert(type(props.OnClick) == "function", "SearchLinkText expects an 'OnClick' function.")
	self.tweenInfo = TweenInfo.new(props.TweenTime or DEFAULT_TWEEN_TIME)

	self.textRef = Roact.createRef()
	self.iconRef = Roact.createRef()
	self.tweens = {}

	self.mouseEnter = function()
		if self.tweens.TextEnter then
			self.tweens.TextEnter:Play()
		end
		if self.tweens.IconEnter then
			self.tweens.IconEnter:Play()
		end
	end

	self.mouseLeave = function()
		if self.tweens.TextLeave then
			self.tweens.TextLeave:Play()
		end
		if self.tweens.IconLeave then
			self.tweens.IconLeave:Play()
		end
	end
end

function SearchLinkText:didMount()
	local text = self.textRef:getValue()
	local icon = self.iconRef:getValue()
	self.tweens.TextEnter = TweenService:Create(text, self.tweenInfo, {
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
	})
	self.tweens.TextLeave = TweenService:Create(text, self.tweenInfo, {
		Position = UDim2.fromScale(1, 0.5),
		AnchorPoint = Vector2.new(1, 0.5),
	})
	self.tweens.IconEnter = TweenService:Create(icon, self.tweenInfo, {
		ImageTransparency = 0,
		AnchorPoint = Vector2.new(1, 0.5),
	})
	self.tweens.IconLeave = TweenService:Create(icon, self.tweenInfo, {
		ImageTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
	})
end

function SearchLinkText:willUnmount()
	for _, tween in pairs(self.tweens) do
		tween:Cancel()
		tween:Destroy()
	end
end

function SearchLinkText:render()
	return withTheme(function(theme)
		local props = self.props
		local text = props.Text
		local position = props.Position
		local anchorPoint = props.AnchorPoint

		local searchLinkTextTheme = theme.assetPreview.description

		local textDimensions
		local textExtents = GetTextSize(text, theme.assetPreview.textSizeLarge)
		textDimensions = UDim2.fromOffset(textExtents.X, textExtents.Y)

		local fullWidth = textExtents.X + searchLinkTextTheme.searchBarIconSize
			+ searchLinkTextTheme.padding

		return Roact.createElement("TextButton", {
			Size = UDim2.new(0, fullWidth, 1, 0),
			Position = position,
			AnchorPoint = anchorPoint,
			BackgroundTransparency = 1,

			Text = "",
			[Roact.Event.Activated] = props.OnClick,
			[Roact.Event.MouseEnter] = self.mouseEnter,
			[Roact.Event.MouseLeave] = self.mouseLeave,
		}, {
			Text = Roact.createElement("TextLabel", {
				Size = textDimensions,
				Position = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,

				Text = text,
				Font = theme.assetPreview.font,
				TextColor3 = searchLinkTextTheme.rightTextColor,
				TextSize = theme.assetPreview.textSizeLarge,
				[Roact.Ref] = self.textRef,
			}),

			SearchIcon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(0, searchLinkTextTheme.searchBarIconSize,
					0, searchLinkTextTheme.searchBarIconSize),
				Position = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				ImageTransparency = 1,

				ImageColor3 = searchLinkTextTheme.rightTextColor,
				Image = searchLinkTextTheme.images.searchIcon,
				[Roact.Ref] = self.iconRef,
			}),
		})
	end)
end

return SearchLinkText
