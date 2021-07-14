--[[
	A back button with a little separator below it.
]]
local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local UILibrary = require(Plugin.UILibrary)

local Separator = require(Plugin.Framework).UI.Separator

local createFitToContent = UILibrary.Component.createFitToContent


local FitToContent = createFitToContent("Frame", "UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 8),
})

local BACK_BUTTON_IMAGE = "rbxasset://textures/GameSettings/ArrowLeft.png"
local BACK_BUTTON_SIZE = 24

return function(props)
	local layoutOrder = props.LayoutOrder
	local onActivated = props.OnActivated

	return Roact.createElement(FitToContent, {
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 4),
		}),

		BackButton = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			Image = BACK_BUTTON_IMAGE,
			Size = UDim2.new(0, BACK_BUTTON_SIZE, 0, BACK_BUTTON_SIZE),
			Rotation = 90,
			LayoutOrder = 1,
			[Roact.Event.Activated] = onActivated,
		}),

		Separator = Roact.createElement(Separator, {
			LayoutOrder = 2,
		}),
	})
end