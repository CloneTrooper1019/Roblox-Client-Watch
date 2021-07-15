local Plugin = script.Parent.Parent.Parent

local isCli = require(Plugin.Core.Util.isCli)

local Background = {}

Background.BACKGROUNDS = {
	{
		name = "White",
		color = "White",
	},
	{
		name = "Black",
		color = "Black",
	},
	{
		name = "None",
		color = "None",
	}
}

-- Indices from the above table so we don't use magic numbers elsewhere
Background.WHITE = 1
Background.BLACK = 2
Background.NONE = 3

function Background.getBackgroundForStudioTheme()
	if isCli() then
		return Background.NONE
	end
	
	local themeName = settings().Studio.Theme.Name

	if themeName == "Light" then
		return Background.WHITE
	elseif themeName == "Dark" then
		-- This is intentional - the transparent background looks better in Dark mode
		return Background.NONE
	else
		return Background.NONE
	end	
end

return Background
