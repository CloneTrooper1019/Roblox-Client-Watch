local Plugin = script.Parent.Parent.Parent

local SetSelectedControlPoints = require(Plugin.Src.Actions.SetSelectedControlPoints)

local TableUtil = require(Plugin.Src.Util.TableUtil)

return function(selection)
	return function(store)
		local selectedControlPoints = {}
		for _, entry in pairs(selection) do
			TableUtil:setNested(selectedControlPoints, {entry.Deformer, entry.ID}, entry.GridPosition)
		end

		store:dispatch(SetSelectedControlPoints(selectedControlPoints))
	end
end