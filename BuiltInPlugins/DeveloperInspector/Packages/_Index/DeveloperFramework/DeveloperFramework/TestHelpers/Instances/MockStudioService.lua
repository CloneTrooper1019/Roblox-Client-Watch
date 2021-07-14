local MockStudioService = {}
MockStudioService.__index = MockStudioService

function MockStudioService.new()
	local self = setmetatable({
		_localUserId = 0,
	}, MockStudioService)

	return self
end

function MockStudioService:Destroy()
end

function MockStudioService:GetUserId()
	return self._localUserId
end

return MockStudioService
