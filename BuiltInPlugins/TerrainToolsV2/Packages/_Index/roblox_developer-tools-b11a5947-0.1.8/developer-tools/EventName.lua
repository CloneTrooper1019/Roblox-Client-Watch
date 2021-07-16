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
		OpenPath = "RoactInspector.OpenPath",
		Highlight = "RoactInspector.GetHighlight",
		Dehighlight = "RoactInspector.Dehighlight",
		-- Profiler
		SetProfiling = "RoactInspector.SetProfiling",
		SetProfileFilter = "RoactInspector.SetProfileFilter",
		SetProfileSearchTerm = "RoactInspector.SetProfileSearchTerm",
		GetProfileData = "RoactInspector.GetProfileData",
		ShowProfileData = "RoactInspector.ShowProfileData",
		SortProfileData = "RoactInspector.SortProfileData",
		ClearProfileData = "RoactInspector.ClearProfileData",
		SelectProfileInstance = "RoactInspector.SelectProfileInstance",
	}, true)
}, true)