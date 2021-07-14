--[[
	Component that displays a rubber band-style selection frame.
]]

local GuiService = game:GetService("GuiService")

local DraggerFramework = script.Parent.Parent
local Library = DraggerFramework.Parent.Parent
local Roact = require(Library.Packages.Roact)

-- Utilities
local Colors = require(DraggerFramework.Utility.Colors)

local DragSelectionView = Roact.PureComponent:extend("DragSelectionView")

DragSelectionView.defaultProps = {
	BackgroundColor3 = Colors.BLACK,
	BackgroundTransparency = 1,
	BorderColor3 = Colors.GRAY,
}

function DragSelectionView:init(initialProps)
	assert(initialProps.DragStartLocation, "Missing required property 'DragStartLocation'.")
	assert(initialProps.DragEndLocation, "Missing required property 'DragEndLocation'.")
end

function DragSelectionView:render()
	local min = self.props.DragStartLocation
	local max = self.props.DragEndLocation
	if not min or not max then
		return nil
	end

	-- Adjust by GUI inset
	local topInset = GuiService:GetGuiInset()

	local rect = Rect.new(min - topInset, max - topInset)

	return Roact.createElement("ScreenGui", {}, {
		Roact.createElement("Frame", {
			Position = UDim2.new(0, rect.Min.X, 0, rect.Min.Y),
			Size = UDim2.new(0, rect.Width, 0, rect.Height),
			BackgroundColor3 = self.props.BackgroundColor3,
			BackgroundTransparency = self.props.BackgroundTransparency,
			BorderSizePixel = 0,
		}, {
			Left = Roact.createElement("Frame", {
				Size = UDim2.new(0, 1, 1, 0),
				BackgroundColor3 = self.props.BorderColor3,
				BorderSizePixel = 0,
			}),
			Top = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = self.props.BorderColor3,
				BorderSizePixel = 0,
			}),
			Right = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, 1, 1, 0),
				BackgroundColor3 = self.props.BorderColor3,
				BorderSizePixel = 0,
			}),
			Bottom = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = self.props.BorderColor3,
				BorderSizePixel = 0,
			}),
		})
	})
end

return DragSelectionView
