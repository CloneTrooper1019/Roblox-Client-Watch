local Plugin = script.Parent.Parent.Parent
local SetCagesTransparency = require(Plugin.Src.Actions.SetCagesTransparency)
local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy

return function(cage, value)
	return function(store)
		local state = store:getState()

		local cagesTransparency = deepCopy(state.selectItem.cagesTransparency)
		cagesTransparency[cage] = value
		store:dispatch(SetCagesTransparency(cagesTransparency))
	end
end