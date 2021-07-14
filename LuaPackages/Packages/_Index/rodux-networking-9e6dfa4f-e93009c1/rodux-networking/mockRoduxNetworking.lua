local makeActionCreator = require(script.Parent.makeActionCreator)

local function makeMockRequestObject(script)
	local request = makeActionCreator(script)

	request.API = function()
		return request.Succeeded()
	end

	return request
end

return function()
	return {
		GET = makeMockRequestObject,
		POST = makeMockRequestObject,
	}
end
