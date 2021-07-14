local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local AssetRenderThumbnail = require(script.Parent)

return function()
	local size = UDim2.new(1, 0, 0, 100)

	local model = Instance.new("Model")
	model.Name = "My Model"

	local script = Instance.new("Script")
	script.Name = "My script with a lovely long name to test wrapping and I'll keep going so it will be long enough."

	return {
		Model = Roact.createElement(AssetRenderThumbnail, {
			Instance = model,
			Size = size,
		}),
		Script = Roact.createElement(AssetRenderThumbnail, {
			Instance = script,
			Size = size,
		}),
	}
end