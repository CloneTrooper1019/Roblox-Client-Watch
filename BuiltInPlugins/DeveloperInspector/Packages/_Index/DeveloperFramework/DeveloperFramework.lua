local strict = require(script.Util.strict)

local FFlagDeveloperTools_v0_1_7 = game:GetFastFlag("DeveloperTools_v0_1_7")

return strict({
	ContextServices = require(script.ContextServices),
	Dash = require(script.packages.Dash),
	DeveloperTools = FFlagDeveloperTools_v0_1_7 and require(script.packages.DeveloperTools) or require(script.packages.DeveloperToolsOld),
	ErrorReporter = require(script.ErrorReporter),
	Http = require(script.Http),
	Resources = require(script.Resources),
	RobloxAPI = require(script.RobloxAPI),
	StudioUI = require(script.StudioUI),
	Style = require(script.Style),
	TestHelpers = require(script.TestHelpers),
	UI = require(script.UI),
	Util = require(script.Util),
	UIData = require(script.UI.UIFolderData),
	Wrappers = require(script.Wrappers),
})