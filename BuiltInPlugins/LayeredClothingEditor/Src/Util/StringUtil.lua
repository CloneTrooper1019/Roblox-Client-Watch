local TextService = game:GetService("TextService")

local StringUtil = {}

local NO_WRAP = Vector2.new(1000000, 50)

function StringUtil.getTextWidth(text, textSize, font)
	return TextService:GetTextSize(text, textSize, font, NO_WRAP).X
end

return StringUtil