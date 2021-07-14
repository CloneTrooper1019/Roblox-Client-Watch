
--[[
	Get the FaceInstance (Decal or Texture) on a given part closest to a given
	position.
]]

local function getNormalId(normalizedPosition)
	local x = math.abs(normalizedPosition.X)
	local y = math.abs(normalizedPosition.Y)
	local z = math.abs(normalizedPosition.Z)
	if x > y and x > z then
		return normalizedPosition.X > 0 and Enum.NormalId.Right or Enum.NormalId.Left
	elseif y > z then
		return normalizedPosition.Y > 0 and Enum.NormalId.Top or Enum.NormalId.Bottom
	else
		return normalizedPosition.Z > 0 and Enum.NormalId.Back or Enum.NormalId.Front
	end
end

local function getFaceInstance(part, position)
	local localPosition = part.CFrame:PointToObjectSpace(position)
	local normalizedPosition = localPosition / part.Size * 2
	local face = getNormalId(normalizedPosition)

	for _, child in pairs(part:GetChildren()) do
		if child:IsA("FaceInstance") and child.Face == face then
			return child
		end
	end
	return nil
end

return getFaceInstance