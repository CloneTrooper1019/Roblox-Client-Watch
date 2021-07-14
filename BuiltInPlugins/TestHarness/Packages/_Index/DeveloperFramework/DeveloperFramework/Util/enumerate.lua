--[[
	Re-export of the enumerate library

	https://roblox.github.io/enumerate/api-reference/
]]

local Framework = script.Parent.Parent

local Util = script.Parent

local FlagsList = require(Util.Flags).new({
	FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
})

local enumerate

local isUsedAsPackage = require(Util.isUsedAsPackage)
local enumerateIsInstalledInParent = Framework.Parent:FindFirstChild("enumerate")
if FlagsList:get("FFlagStudioDevFrameworkPackage") and isUsedAsPackage() and enumerateIsInstalledInParent then
	enumerate = require(Framework.Parent.enumerate :: any)
else
	enumerate = require(Framework.packages.enumerate :: any)
end

return enumerate