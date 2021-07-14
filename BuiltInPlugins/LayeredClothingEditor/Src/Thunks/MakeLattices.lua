local Plugin = script.Parent.Parent.Parent

local Constants = require(Plugin.Src.Util.Constants)

local SetSubdivisions = require(Plugin.Src.Thunks.SetSubdivisions)

return function()
	return function(store)
		local state = store:getState()

		local boundsData = state.cageData.boundsData
		if not boundsData then
			return
		end

		if boundsData[Enum.CageType.Outer] then
			for deformer in pairs(boundsData[Enum.CageType.Outer]) do
				store:dispatch(SetSubdivisions(Constants.DEFAULT_LATTICE_SUBDIVISIONS, deformer, Enum.CageType.Outer, true))
			end
		end

		if boundsData[Enum.CageType.Inner] then
			for deformer in pairs(boundsData[Enum.CageType.Inner]) do
				store:dispatch(SetSubdivisions(Constants.DEFAULT_LATTICE_SUBDIVISIONS, deformer, Enum.CageType.Inner, true))
			end
		end
	end
end