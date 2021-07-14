local AssetType = {}

AssetType.TYPES = {
	ModelType = 1, -- MeshPart, Mesh, Model
	ImageType = 2,
	SoundType = 3,  -- Sound comes with the model or mesh.
	ScriptType = 4, -- Server, local, module
	PluginType = 5,
	OtherType = 6,
	LoadingType = 7,
	VideoType = 8,
}

-- For check if we show preview button or not.
AssetType.AssetTypesPreviewEnabled = {
	[Enum.AssetType.Mesh.Value] = true,
	[Enum.AssetType.MeshPart.Value] = true,
	[Enum.AssetType.Model.Value] = true,
	[Enum.AssetType.Decal.Value] = true,
	[Enum.AssetType.Image.Value] = true,
	[Enum.AssetType.Audio.Value] = true,
	[Enum.AssetType.Lua.Value] = true,
	[Enum.AssetType.Plugin.Value] = true,
	[Enum.AssetType.Video.Value] = true,
}

local classTypeMap = {
	BasePart = AssetType.TYPES.ModelType,
	Model = AssetType.TYPES.ModelType,
	BackpackItem = AssetType.TYPES.ModelType,
	Accoutrement = AssetType.TYPES.ModelType,
	Part =  AssetType.TYPES.ModelType,

	Decal = AssetType.TYPES.ImageType,
	ImageLabel = AssetType.TYPES.ImageType,
	ImageButton = AssetType.TYPES.ImageType,
	Texture =AssetType.TYPES.ImageType,
	Sky = AssetType.TYPES.ImageType,

	Sound = AssetType.TYPES.SoundType,
	VideoFrame = AssetType.TYPES.VideoType,

	BaseScript = AssetType.TYPES.ScriptType,
}

classTypeMap.MeshPart = AssetType.TYPES.ModelType

-- For AssetPreview, we divide assets into four categories.
-- For any parts or meshes, we will need to do a model preview.
-- For images, we show only an image.
-- For sound, we will need to show something and provide play control. (Will
-- probably improve this in the future)
-- For BaseScript, show only names while for all other types show assetName and type
function AssetType:getAssetType(assetInstance)
	local notInstance = not assetInstance or typeof(assetInstance) ~= "Instance"

	if notInstance then
		return self.TYPES.LoadingType
	end
	local className = assetInstance.className
	local type = classTypeMap[className]

	if not type then
		return self.TYPES.OtherType
	end

	return type
end

function AssetType:isModel(currentType)
	return currentType == self.TYPES.ModelType
end

function AssetType:isImage(currentType)
	return currentType == self.TYPES.ImageType
end

function AssetType:isAudio(currentType)
	return currentType == self.TYPES.SoundType
end

function AssetType:isScript(currentType)
	return currentType == self.TYPES.ScriptType
end

function AssetType:isPlugin(currentType)
	return currentType == self.TYPES.PluginType
end

function AssetType:markAsPlugin()
	return self.TYPES.PluginType
end

function AssetType:isOtherType(currentType)
	return currentType == self.TYPES.OtherType
end

function AssetType:isLoading(currentType)
	return currentType == self.TYPES.LoadingType
end

function AssetType:isVideo(currentType)
	return currentType == self.TYPES.VideoType
end

function AssetType:isPreviewAvailable(typeId)
	assert(typeId ~= nil, "AssetPreviewType can't be nil")
	return AssetType.AssetTypesPreviewEnabled[typeId] ~= nil
end

return AssetType