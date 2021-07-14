--[[
	Component that displays a dot of fixed size at the given position.
	Intended to be used to show the center of the current selection.
]]
local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent
local Library = DraggerFramework.Parent.Parent
local Roact = require(Library.Packages.Roact)

local Colors = require(DraggerFramework.Utility.Colors)

local SelectionDot = Roact.Component:extend("SelectionDot")

SelectionDot.defaultProps = {
	BackgroundColor3 = Colors.WHITE,
	BorderColor3 = Colors.BLACK,
	Position = Vector3.new(),
	Size = 3,
}

function SelectionDot:render()
	local screenPosition, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(self.props.Position)
	if not onScreen then
		return nil
	end

	local size = self.props.Size

	return Roact.createElement("ScreenGui", {}, {
		Roact.createElement("Frame", {
			BackgroundColor3 = self.props.BackgroundColor3,
			BorderColor3 = self.props.BorderColor3,
			BorderSizePixel = 1,
			Position = UDim2.new(0, screenPosition.X, 0, screenPosition.Y),
			Selectable = false,
			Size = UDim2.new(0, size, 0, size),
		})
	})
end

return SelectionDot
