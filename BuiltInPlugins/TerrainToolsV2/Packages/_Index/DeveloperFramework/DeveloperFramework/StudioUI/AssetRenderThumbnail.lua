--[[
	Renders the class icon for an instance and the instance's name.

	Required Props:
		Instance Instance: The instance to render a thumbnail for.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Vector2 AnchorPoint: The pivot point of this component's Position prop.
		UDim2 Position: The position of this component.
		UDim2 Size: The size of this component.
		UDim2 IconSize: The size of the icon.
]]
local StudioService = game:GetService("StudioService")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local UI = require(Framework.UI)
local Container = UI.Container
local Decoration = UI.Decoration
local Image = Decoration.Image
local TextLabel = Decoration.TextLabel

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local AssetRenderThumbnail = Roact.PureComponent:extend("AssetRenderThumbnail")
Typecheck.wrap(AssetRenderThumbnail, script)

function AssetRenderThumbnail.getClassIcon(instance)
	local className = instance.ClassName
	if instance.IsA then
		if instance:IsA("JointInstance") and className == "ManualWeld" or className == "ManualGlue" then
			return StudioService:GetClassIcon("JointInstance")
		end
	end
	return StudioService:GetClassIcon(className)
end

function AssetRenderThumbnail:render()
	local props = self.props

	local instance = props.Instance
	local iconInfo = AssetRenderThumbnail.getClassIcon(instance)

	local position = props.Position
	local size = props.Size
	local anchorPoint = props.AnchorPoint
	local DEFAULT_ICON_SCALE = 0.25
	local iconSize = props.IconSize or UDim2.new(DEFAULT_ICON_SCALE, 0, DEFAULT_ICON_SCALE, 0)

	return Roact.createElement(Container, {
		AnchorPoint = anchorPoint,
		Position = position,
		Size = size,
	},{
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		InstanceIcon = Roact.createElement(Image, {
			LayoutOrder = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Style = {
				Size = iconSize,
				Image = iconInfo.Image,
				ImageRectSize = iconInfo.ImageRectSize,
				ImageRectOffset = iconInfo.ImageRectOffset,
			},
		}),

		InstanceName = Roact.createElement(TextLabel, {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 1 - iconSize.Y.Scale, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = instance.Name or "",
			TextTruncate = Enum.TextTruncate.AtEnd
		})
	})
end

ContextServices.mapToProps(AssetRenderThumbnail, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return AssetRenderThumbnail


