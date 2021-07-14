local TextService = game:GetService("TextService")

local FStringMainFont = game:DefineFastString("StudioBuiltinPluginDefaultFont", "Gotham")

local FONT_SIZE_MEDIUM = 16
local FONT = Enum.Font.Gotham
pcall(function()
	FONT = Enum.Font[FStringMainFont]
end)

local function GetTextSize(text, fontSize, font, frameSize)

	fontSize = fontSize or FONT_SIZE_MEDIUM
	font = font or FONT
	frameSize = frameSize or Vector2.new(math.huge, math.huge)

	return TextService:GetTextSize(text, fontSize, font, frameSize)
end

return GetTextSize