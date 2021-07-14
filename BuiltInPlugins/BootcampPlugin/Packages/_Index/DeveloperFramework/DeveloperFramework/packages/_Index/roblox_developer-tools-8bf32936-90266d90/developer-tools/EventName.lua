local Source = script.Parent
local Packages = Source.Parent

local Dash = require(Packages.Dash)
local freeze = Dash.freeze

return freeze("EventName", {
	CloseTarget = "CloseTarget",
	GetTargets = "GetTargets",
	ShowTargets = "ShowTargets",
	AttachTarget = "AttachTarget",
	RoactInspector = freeze("EventName.RoactInspector", {
		GetChildren = "RoactInspector.GetChildren",
		ShowChildren = "RoactInspector.ShowChildren",
		GetBranch = "RoactInspector.GetBranch",
		ShowBranch = "RoactInspector.ShowBranch",
		GetFields = "RoactInspector.GetFields",
		ShowFields = "RoactInspector.ShowFields",
		SetPicking = "RoactInspector.SetPicking",
		PickInstance = "RoactInspector.PickInstance",
		Highlight = "RoactInspector.GetHighlight",
		Dehighlight = "RoactInspector.Dehighlight",
	}, true)
}, true)