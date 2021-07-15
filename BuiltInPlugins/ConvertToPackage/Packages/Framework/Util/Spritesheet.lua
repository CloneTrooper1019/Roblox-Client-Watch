--[[
	Parses spritesheets into a list of sprites that you can then join with Roact ImageLabel/Button props
	Sprites are returned in the order they appear in the spritesheet in the form of:
	{
		Image = asset,
		ImageRectSize = SpriteSize,
		ImageRectOffset = positionOfSpriteInSheet,
	}

	Required arguments:
		string asset - AssetId or path to the spritesheet
		table props - Table of properties, similar to creating a Roact element

	Required props:
		number/Vector2 SpriteSize - how large each sprite is (must be the same for all sprites)
									a number SpriteSize is converted to a uniform Vector2
		number NumSprites - how many sprites there are in the spritesheet

	Optional props:
		number SpritesheetWidth - how wide the entire spritesheet is. Defaults to 1024 (max image size)
								  You do not need to change this unless you break your sprites onto a new
								  line before X=1024 when there is still enough room for another sprite, or
								  your spritesheet is wider than 1024 (Don't do this! The engine will automatically
								  downscale images larger than the max size)

	Example usage:

	local expandButton = Spritesheet("rbxasset://textures/folder/expand.png", {
		SpriteSize = 32,
		NumSprites = 4,
	}

	local onStateImageProps = expandButton[1]
	local offStateImageProps = expandButton[2]

	component:render()
		local expandImageProps = self.state.expanded and onStateImage or offStateImage
		Roact.createElement("ImageLabel", Cryo.Dictionary.join(expandImageProps, {
		    ...
		}))
]]

-- TODO check if 1K limitation is necessary in /content or only web
local MAX_IMAGE_SIZE = 1024

local function Spritesheet(image, props)
	local spriteSizeType = typeof(props.SpriteSize)
	local spriteCountType = typeof(props.NumSprites)
	local sheetWidthType = typeof(props.SpritesheetWidth)

	assert(spriteSizeType == "number" or spriteSizeType == "Vector2",
		"SpriteSize must be number or Vector2. Got type '"..spriteSizeType.."'")
	assert(spriteCountType == "number",
		"NumSprites must be number. Got type'"..spriteCountType.."'")
	assert(sheetWidthType == "number" or sheetWidthType == "nil",
		"SpritesheetWidth must be a number or nil. Got '"..sheetWidthType.."'")

	local spriteSize = spriteSizeType == "number" and Vector2.new(1, 1) * props.SpriteSize or props.SpriteSize
	local numSprites = props.NumSprites
	local sheetWidth = props.SpritesheetWidth or MAX_IMAGE_SIZE

	assert(spriteSize.X > 0 and spriteSize.Y > 0,
		"SpriteSize does not support <= 0 values. Got '"..tostring(spriteSize).."'")
	assert(numSprites > 0,
		"NumSprites must be > 0. Got '"..numSprites)
	assert(sheetWidth > 0,
		"SpritesheetWidth does not support <= 0 values. Got '"..sheetWidth.."'")

	local sprites = {}

	local numColumns = math.floor(sheetWidth / spriteSize.X)
	for i = 0, props.NumSprites - 1 do
		local row = math.floor(i / numColumns)
		local column = i % numColumns

		table.insert(sprites, {
			Image = image,
			ImageRectSize = spriteSize,
			ImageRectOffset = Vector2.new(column * spriteSize.X, row * spriteSize.Y),
		})
	end

	return sprites
end

return Spritesheet