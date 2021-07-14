--[[
	Renders an instance or thumbnail.

	Required Props:
		any Image: The Image to render. This can be an Instance or an asset URL string.

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

local UI = require(Framework.UI)
local Container = UI.Container
local Decoration = UI.Decoration
local Image = Decoration.Image

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local AssetRenderImage = Roact.PureComponent:extend("AssetRenderImage")
Typecheck.wrap(AssetRenderImage, script)

local function getImage(image)
	if typeof(image) ~= "Instance" then
		return image
	end

	if image:IsA("Decal") or image:IsA("Texture") then
		return image.Texture
	elseif image:IsA("Sky") then
		return image.SkyboxFt
	else
		return image.Image
	end
end

local function getImageScaleType(image)
	if typeof(image) ~= "Instance" then
		return Enum.ScaleType.Fit
	end

	if image:IsA("Sky") then
		return Enum.ScaleType.Crop
	else
		return Enum.ScaleType.Fit
	end
end

function AssetRenderImage:render()
	local props = self.props
	local position = props.Position
	local size = props.Size or UDim2.new(1, 0, 1, 0)
	local image = props.Image

	return Roact.createElement(Container, {
		Position = position,
		Size = size,
		Background = Decoration.Box,
	},{
		Image = Roact.createElement(Image, {
			Style = {
				ScaleType = getImageScaleType(image),
				Image = getImage(image),
			},
		})
	})
end

ContextServices.mapToProps(AssetRenderImage, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return AssetRenderImage
