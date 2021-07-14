local Workspace = game.Workspace
local PublishService = game:GetService("PublishService")

local Plugin = script.Parent.Parent.Parent

local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

return function(editingItem, sourceItem)
	return function(store)
		if not editingItem then
			return
		end

		local state = store:getState()
		local pointData = state.cageData.pointData

		editingItem.Archivable = true
		local clone = editingItem:Clone()
		editingItem.Archivable = false

		-- temporary bug workaround: LC item needs to be a child of a model in order for cage editing to happen
		local tempModel
		local isClothes = ItemCharacteristics.isClothes(editingItem)
		local previousPosition
		if isClothes then
			tempModel = Instance.new("Model", Workspace)
			tempModel.Name = sourceItem.Name
			clone.Parent = tempModel
			clone.Name = "Handle"
		end

		ModelUtil:createDeformerToPartMap(clone, not isClothes)
		ModelUtil:updateWraps(pointData, Enum.CageType.Inner)
		ModelUtil:updateWraps(pointData, Enum.CageType.Outer)

		if isClothes then
			local wrap = clone:FindFirstChildWhichIsA("WrapLayer")
			previousPosition = clone.CFrame.Position
			editingItem.CFrame = (wrap.ImportOrigin * wrap.CageOrigin):inverse()
			local weld = clone:FindFirstChildWhichIsA("WeldConstraint")
			weld:Destroy()
		end

		local newIdsInner = {}
		local newIdsOuter = {}
		if isClothes then
			for _, deformer in pairs(ModelUtil:getDeformerToPartMap()) do
				local id = PublishService:PublishCageMeshAsync(deformer, Enum.CageType.Inner)
				newIdsInner[deformer] = id
			end
		end
		for _, deformer in pairs(ModelUtil:getDeformerToPartMap()) do
			local id = PublishService:PublishCageMeshAsync(deformer, Enum.CageType.Outer)
			newIdsOuter[deformer] = id
		end

		for _, desc in ipairs(clone:GetDescendants()) do
			if newIdsInner[desc] then
				desc.ReferenceMeshId = newIdsInner[desc]
			end
			if newIdsOuter[desc] then
				desc.CageMeshId = newIdsOuter[desc]
			end
		end

		-- parent completed item to accessory instance
		if isClothes then
			clone.CFrame = CFrame.new(previousPosition)
			local accessory = Instance.new("Accessory", Workspace)
			clone.Parent = accessory
			accessory.Name = tempModel.Name
			tempModel:Destroy()
		end
	end
end