local NO_COLLISIONS_TRANSPARENCY = 0.4

local TemporaryTransparency = {}
TemporaryTransparency.__index = TemporaryTransparency

function TemporaryTransparency.new(parts)
	local self = setmetatable({
		_draggingModifiedParts = {},
	}, TemporaryTransparency)

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = NO_COLLISIONS_TRANSPARENCY
			table.insert(self._draggingModifiedParts, part)
		end
	end

	return self
end

function TemporaryTransparency:destroy()
	for _, part in ipairs(self._draggingModifiedParts) do
		part.LocalTransparencyModifier = 0
	end
end

return TemporaryTransparency