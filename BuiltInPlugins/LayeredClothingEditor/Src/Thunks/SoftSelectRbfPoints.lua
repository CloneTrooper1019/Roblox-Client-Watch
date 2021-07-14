local Plugin = script.Parent.Parent.Parent

local SetSelectedPoints = require(Plugin.Src.Actions.SetSelectedPoints)

local TableUtil = require(Plugin.Src.Util.TableUtil)

local function preSelectClickedPoints(state, clickedPoints)
	local selectedPoints = {}
	for _, clickedPoint in ipairs(clickedPoints) do
		TableUtil:setNested(selectedPoints, {clickedPoint.Deformer, clickedPoint.Index}, 1)
	end
	return selectedPoints
end

local function shouldWeightPoint(selectedPoints, deformer, index)
	return not selectedPoints[deformer] or selectedPoints[deformer][index] == nil or selectedPoints[deformer][index] < 1
end

local function setPointWeight(state, selectedPoints, deformer, index, distance)
	local falloff = state.pointTool.falloff
	local weight = 1 - (distance / falloff)
	TableUtil:initNested(selectedPoints, {deformer, index}, 0)
	local selectedPointWeight = selectedPoints[deformer][index]
	selectedPoints[deformer][index] = math.max(selectedPointWeight, math.clamp(selectedPointWeight + weight, 0, 1))
end

local function softSelect(state, selectedPoints, clickedPoints)
	local pointData = state.cageData.pointData
	local editingCage = state.selectItem.editingCage
	local falloff = state.pointTool.falloff
	local seamData = state.cageData.seamData
	local polyData = state.cageData.polyData

	local firstClickedPoint = clickedPoints[1]

	if not firstClickedPoint or falloff == 0 then
		return
	end
	local firstPointData = pointData[editingCage][firstClickedPoint.Deformer][firstClickedPoint.Index]
	local face = firstPointData.Faces[1]

	local visited = {}

	local queue = {
		{
			Index = polyData[editingCage][firstClickedPoint.Deformer][face][1],
			Deformer = firstClickedPoint.Deformer,
			Distance = 0
		},
	}

	-- bfs of mesh using vertex indices from faces to see how points are connected
	while #queue > 0 do
		local current = queue[1]
		if not visited[current.Deformer] or not visited[current.Deformer][current.Index] then
			if shouldWeightPoint(selectedPoints, current.Deformer, current.Index) then
				local distance = current.Distance
				if distance < falloff then
					setPointWeight(state, selectedPoints, current.Deformer, current.Index, distance)
				end
			else
				-- you are next to a point that was pre-selected, start your distance at 0
				current.Distance = 0
			end
			TableUtil:setNested(visited, {current.Deformer, current.Index}, true)
			local point = pointData[editingCage][current.Deformer][current.Index]
			local faces = point.Faces
			for _, faceIndex in ipairs(faces) do
				local face = polyData[editingCage][current.Deformer][faceIndex]
				for _, vi in ipairs(face) do
					if vi ~= current.Index then
						local nextPoint = pointData[editingCage][current.Deformer][vi]
						local distance = (nextPoint.Position - point.Position).Magnitude
						if current.Distance + distance < falloff then
							table.insert(queue, {
								Index = vi,
								Deformer = current.Deformer,
								Distance = current.Distance + distance,
							})
						end
					end
				end
			end
			local linkPoints = seamData[editingCage][current.Deformer] and seamData[editingCage][current.Deformer][current.Index]
			if linkPoints then
				for _, linkPoint in ipairs(linkPoints) do
					if current.Distance < falloff then
						table.insert(queue, {
							Index = linkPoint.Index,
							Deformer = linkPoint.Deformer,
							Distance = current.Distance,
						})
					end
				end
			end
		end
		table.remove(queue, 1)
	end
end

return function()
	return function(store)
		local state = store:getState()

		local clickedPoints = state.pointTool.clickedPoints

		local selectedPoints = preSelectClickedPoints(state, clickedPoints)

		softSelect(state, selectedPoints, clickedPoints)

		store:dispatch(SetSelectedPoints(selectedPoints))
	end
end