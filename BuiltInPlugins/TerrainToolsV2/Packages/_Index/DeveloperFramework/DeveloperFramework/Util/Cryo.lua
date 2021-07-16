local Framework = script.Parent.Parent
local Cryo

local FlagsList = require(script.Parent.Flags).new({
	FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
})

local isUsedAsPackage = require(Framework.Util.isUsedAsPackage)
if FlagsList:get("FFlagStudioDevFrameworkPackage") and isUsedAsPackage() then
	Cryo = require(Framework.Parent.Cryo)
else
	Cryo = require(Framework.packages.Cryo)
end

return Cryo