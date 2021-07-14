local Plugin = script.Parent.Parent.Parent

local SetClickedPoints = require(Plugin.Src.Actions.SetClickedPoints)

local SoftSelectRbfPoints = require(Plugin.Src.Thunks.SoftSelectRbfPoints)

return function(clicked)
	return function(store)
		store:dispatch(SetClickedPoints(clicked))
		store:dispatch(SoftSelectRbfPoints())
	end
end