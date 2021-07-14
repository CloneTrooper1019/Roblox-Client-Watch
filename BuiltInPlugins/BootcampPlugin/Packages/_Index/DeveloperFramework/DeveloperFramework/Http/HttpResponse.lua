--[[
	HttpResponse

	Encapsulates the response from an http request. Nothing fancy
]]

local HttpResponse = {}
HttpResponse.__tostring = function(hr)
	local requestFields = {}
	for k, v in pairs(hr.requestOptions) do
		table.insert(requestFields, string.format("%s : %s", k, tostring(v)))
	end

	local responseBody = hr.responseBody
	if type(responseBody) == "table" then
		local responseFields = {}
		for k, v in pairs(responseBody) do
			table.insert(responseFields, string.format("%s : %s", k, tostring(v)))
		end
		responseBody = string.format("{ %s }", table.concat(responseFields, ", "))
	end

	local fields = {}
	table.insert(fields, string.format("%s : %s", "responseTimeMs", hr.responseTimeMs))
	table.insert(fields, string.format("%s : %s", "responseCode", hr.responseCode))
	table.insert(fields, string.format("%s : %s", "responseBody", responseBody))
	table.insert(fields, string.format("%s : { %s }", "requestOptions", table.concat(requestFields, ", ")))


	return string.format("HttpResponse = { %s }", table.concat(fields, ", "))
end

function HttpResponse.new(response, responseTime, statusCode, requestOptions)
	local hr = {
		responseTimeMs = responseTime,
		responseCode = statusCode,
		responseBody = response,
		requestOptions = requestOptions,
	}
	setmetatable(hr, HttpResponse)

	return hr
end

return HttpResponse
