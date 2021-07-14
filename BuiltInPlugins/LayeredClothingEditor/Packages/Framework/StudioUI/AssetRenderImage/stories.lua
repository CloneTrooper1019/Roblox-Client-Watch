local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

return function()
	-- Asset IDs used in examples are Roblox-owned

	local AssetRenderImage = require(script.Parent)

	local decal = Instance.new("Decal")
	decal.Texture = "rbxassetid://23156312"

	local texture = Instance.new("Texture")
	texture.Texture = "rbxassetid://23156312"

	local sky = Instance.new("Sky")
	sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"

	local size = UDim2.new(1, 0, 0, 100)

	return {
		Decal = Roact.createElement(AssetRenderImage, {
			Size = size,
			Image = decal,
		}),
		Texture = Roact.createElement(AssetRenderImage, {
			Size = size,
			Image = texture,
		}),
		Sky = Roact.createElement(AssetRenderImage, {
			Size = size,
			Image = sky,
		}),
		Thumbnail = Roact.createElement(AssetRenderImage, {
			Size = size,
			Image = "rbxthumb://type=Asset&id=23156312&w=420&h=420",
		}),
	}
end