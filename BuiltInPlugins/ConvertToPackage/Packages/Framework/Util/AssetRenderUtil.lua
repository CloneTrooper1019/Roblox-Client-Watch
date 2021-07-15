local Framework = script.Parent.Parent

local enumerate = require(Framework.Util.enumerate)

local AssetRenderUtil = {}

AssetRenderUtil.AssetRenderType = enumerate("AssetRenderType", {
	"Model",
	"Image",
	"Sound",
	"Script",
	"Video",
	"Other",
})

local CLASS_TO_TYPE = {
	BasePart = AssetRenderUtil.AssetRenderType.Model,
	Model = AssetRenderUtil.AssetRenderType.Model,
	BackpackItem = AssetRenderUtil.AssetRenderType.Model,
	Accoutrement = AssetRenderUtil.AssetRenderType.Model,
	Part = AssetRenderUtil.AssetRenderType.Model,
	MeshPart = AssetRenderUtil.AssetRenderType.Model,

	Decal = AssetRenderUtil.AssetRenderType.Image,
	ImageLabel = AssetRenderUtil.AssetRenderType.Image,
	ImageButton = AssetRenderUtil.AssetRenderType.Image,
	Texture = AssetRenderUtil.AssetRenderType.Image,
	Sky = AssetRenderUtil.AssetRenderType.Image,

	Sound = AssetRenderUtil.AssetRenderType.Sound,

	VideoFrame = AssetRenderUtil.AssetRenderType.Video,

	BaseScript = AssetRenderUtil.AssetRenderType.Script,
}

--[[
	Determines which rendering should be shown for an asset.

	Returns nil if the input is not an instance.
]]
function AssetRenderUtil:getRenderType(assetInstance)
	local notInstance = not assetInstance or typeof(assetInstance) ~= "Instance"

	if notInstance then
		return nil
	end

	local className = assetInstance.className
	local typeForClass = CLASS_TO_TYPE[className]

	if typeForClass then
		return typeForClass
	end

	return AssetRenderUtil.AssetRenderType.Other
end

return AssetRenderUtil