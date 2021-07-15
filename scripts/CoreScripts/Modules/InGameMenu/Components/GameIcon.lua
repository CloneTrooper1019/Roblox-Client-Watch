--[[
	A square game icon
]]

local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local UIBlox = InGameMenuDependencies.UIBlox
local t = InGameMenuDependencies.t
local InGameMenu = script.Parent.Parent

local withStyle = UIBlox.Core.Style.withStyle
local Images = UIBlox.App.ImageSet.Images
local AssetImage = require(InGameMenu.Components.AssetImage)
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local getGameIconRequestSize = require(InGameMenu.Components.getGameIconRequestSize)

local MAX_PLACEHOLDER_SIZE = 44

local GameIcon = Roact.PureComponent:extend("GameIcon")

GameIcon.validateProps = t.strictInterface({
	gameId = t.number,
	iconSize = t.numberMin(0),
	layoutOrder = t.optional(t.number),
	cornerRadius = t.optional(t.UDim),
})

function GameIcon:render()
	local iconSize = self.props.iconSize
	local requestIconSize = getGameIconRequestSize(iconSize)
	local gameId = self.props.gameId
	local cornerRadius = self.props.cornerRadius

	local iconUrl = ("rbxthumb://type=GameIcon&id=%d&w=%d&h=%d"):format(
		gameId,
		requestIconSize,
		requestIconSize
	)

	--Special case for when the gameId is not available. For example developing in studio with a un-published game.
	local isPlaceholder = gameId == 0

	if isPlaceholder then
		local placeholderIconSize = MAX_PLACEHOLDER_SIZE
		if iconSize <= MAX_PLACEHOLDER_SIZE then
			placeholderIconSize = iconSize
		end
		return withStyle(function(style)
			return Roact.createElement(AssetImage.Label, {
				imageKey = "RoundedRect",
				Size = UDim2.fromOffset(iconSize, iconSize),
				ImageColor3 = style.Theme.PlaceHolder.Color,
				ImageTransparency = style.Theme.PlaceHolder.Transparency,
				LayoutOrder = self.props.layoutOrder,
			}, {
				PlaceholderIcon = Roact.createElement(ImageSetLabel, {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(placeholderIconSize, placeholderIconSize),
					Position = UDim2.fromScale(0.5, 0.5),
					Image = Images["icons/imageUnavailable"],
					ImageColor3 = style.Theme.UIDefault.Color,
					ImageTransparency = style.Theme.UIDefault.Transparency,
					AnchorPoint = Vector2.new(0.5, 0.5),
				}, {
					UICorner = cornerRadius and cornerRadius ~= UDim.new(0, 0) and Roact.createElement("UICorner", {
						CornerRadius = cornerRadius,
					}) or nil,
				}),
			})
		end)
	else
		return Roact.createElement("ImageLabel", {
			Image = iconUrl,
			Size = UDim2.fromOffset(iconSize, iconSize),
			BackgroundTransparency = 1,
			LayoutOrder = self.props.layoutOrder,
		}, {
			UICorner = cornerRadius and cornerRadius ~= UDim.new(0, 0) and Roact.createElement("UICorner", {
				CornerRadius = cornerRadius,
			}) or nil,
		})
	end
end

return GameIcon
