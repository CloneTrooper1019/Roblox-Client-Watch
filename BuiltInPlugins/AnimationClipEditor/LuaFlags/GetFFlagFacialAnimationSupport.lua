local Plugin = script.Parent.Parent
local GetFFlagPrecalculatePartPaths = require(Plugin.LuaFlags.GetFFlagPrecalculatePartPaths)
local GetFFlagRefactorMenus = require(Plugin.LuaFlags.GetFFlagRefactorMenus)

game:DefineFastFlag("ACEFacialAnimationSupport", false)

return function()
	return GetFFlagPrecalculatePartPaths()
		and GetFFlagRefactorMenus()
		and game:GetFastFlag("ACEFacialAnimationSupport")
end