--[[
	Format:
	{
		[deformer1] = {
			[<point_index>] = {
				Cluster = <cluster_index>, -- default -1
				Position = <Vector3>,
			},
			...
		},

		[deformer2] = {
			[<point_index>] = {
				Cluster = <cluster_index>, -- default -1
				Position = <Vector3>,
			},
			...
		},
		...
	}
]]

local Plugin = script.Parent.Parent.Parent

local SetPointData = require(Plugin.Src.Actions.SetPointData)
local SetOriginalPointData = require(Plugin.Src.Actions.SetOriginalPointData)
local SetPolyData = require(Plugin.Src.Actions.SetPolyData)
local GetSeamData = require(Plugin.Src.Thunks.GetSeamData)
local GetBounds = require(Plugin.Src.Thunks.GetBounds)
local MockRbfData = require(Plugin.Src.Resources.MockRbfData)

local Framework = require(Plugin.Packages.Framework)
local Util = Framework.Util
local deepCopy = Util.deepCopy

local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local DebugFlags = require(Plugin.Src.Util.DebugFlags)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local function getVertices(cage)
	local deformerToPartMap = ModelUtil:getDeformerToPartMap()
	local pointsPerDeformer = {}
	for _, deformer in pairs(deformerToPartMap) do
		local verts = deformer:GetVertices(cage)
		local data = {}
		for _, vert in ipairs(verts) do
			table.insert(data, {
				Position = vert,
				Faces = {},
			})
		end
		pointsPerDeformer[deformer.Name] = data
	end
	return pointsPerDeformer
end

local function getFaces(pointData, cage)
	local deformerToPartMap = ModelUtil:getDeformerToPartMap()
	local facesPerDeformer = {}
	for _, deformer in pairs(deformerToPartMap) do
		local faces = deformer:GetFaces(cage)
		local data = {}
		for i = 1, #faces, 3 do
			table.insert(data, {faces[i] + 1, faces[i + 1] + 1, faces[i + 2] + 1})
			table.insert(pointData[deformer.Name][faces[i] + 1].Faces, #data)
			table.insert(pointData[deformer.Name][faces[i + 1] + 1].Faces, #data)
			table.insert(pointData[deformer.Name][faces[i + 2] + 1].Faces, #data)
		end
		facesPerDeformer[deformer.Name] = data
	end
	return facesPerDeformer
end

return function(editingItem)
	return function(store)
		local state = store:getState()
		if editingItem then
			local basePointData = {}
			local polyData = {}
			local isClothes = false
			if ItemCharacteristics.isAvatar(editingItem) then
				ModelUtil:createDeformerToPartMap(editingItem, true)
			elseif ItemCharacteristics.isClothes(editingItem) then
				ModelUtil:createDeformerToPartMap(editingItem, false)
				isClothes = true
			else
				return
			end

			if not next(ModelUtil:getDeformerToPartMap()) then
				store:dispatch(SetPointData({}))
				store:dispatch(SetOriginalPointData({}))
				store:dispatch(SetPolyData({}))
				return
			end

			if DebugFlags.UseMockCages() then
				if isClothes then
					local name = next(ModelUtil:getDeformerToPartMap())
					basePointData[Enum.CageType.Inner] = { [name] = deepCopy(MockRbfData["UpperTorso"])}
					basePointData[Enum.CageType.Outer] = { [name] = deepCopy(MockRbfData["UpperTorso"])}
				else
					basePointData[Enum.CageType.Inner] = deepCopy(MockRbfData)
					basePointData[Enum.CageType.Outer] = deepCopy(MockRbfData)
				end
			else
				if isClothes then
					basePointData[Enum.CageType.Inner] = getVertices(Enum.CageType.Inner)
					polyData[Enum.CageType.Inner] = getFaces(basePointData[Enum.CageType.Inner], Enum.CageType.Inner)
				end

				basePointData[Enum.CageType.Outer] = getVertices(Enum.CageType.Outer)
				polyData[Enum.CageType.Outer] = getFaces(basePointData[Enum.CageType.Outer], Enum.CageType.Outer)
			end

			store:dispatch(SetPointData(basePointData))
			store:dispatch(SetOriginalPointData(deepCopy(basePointData)))
			store:dispatch(SetPolyData(polyData))

			if isClothes then
				store:dispatch(GetBounds(Enum.CageType.Outer))
				store:dispatch(GetSeamData(Enum.CageType.Outer))

				store:dispatch(GetBounds(Enum.CageType.Inner))
				store:dispatch(GetSeamData(Enum.CageType.Inner))
			else
				store:dispatch(GetBounds(Enum.CageType.Outer))
				store:dispatch(GetSeamData(Enum.CageType.Outer))
			end
		end
	end
end