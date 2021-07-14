-- create a fake backend to respond to network requests in a reliable way in tests

local HttpService = game:GetService("HttpService")

local function findQuestionMark(url)
	return url and string.find(tostring(url), "?")
end

-- for the url https://develop.roblox.com/v1/assets?assetIds=12345,6789,9999 this would return the
-- end point which is everything before the question mark i.e https://develop.roblox.com/v1/assets
local function getEndpoint(url)
	local index = findQuestionMark(url)
	return (index and index > 1) and url:sub(1, index-1) or nil
end

-- for the url https://develop.roblox.com/v1/assets?assetIds=12345,6789,9999 this would return the
-- args which is everything after the question mark i.e assetIds=12345,6789,9999
local function getArgs(url)
	local index = findQuestionMark(url)
	return (index and index < string.len(url)) and url:sub(index+1) or nil
end

local function mockNetworkLayer(requestOptions)
	local responses = {
		["https://develop.roblox.com/v1/assets"] = function(args)
			local function parseIds(argString)
				local results = {}
				argString = string.gsub(argString, "^assetIds=", "")
				for match in (argString..","):gmatch("(.-),") do
					local num = tonumber(match)
					if num then
						table.insert(results, num)
					end
				end
				return results
			end

			local assetIds = parseIds(args)
			local result = {
				data = {
				}
			}
			for index, singleAssetId in ipairs(assetIds) do
				result.data[index] = {
					canHaveThumbnail = false,
					isArchivable = false,
					id = singleAssetId,
					isPublicDomainEnabled = false,
					typeId = 19,
					isModerated = false,
					isVersioningEnabled = false,
					name = "Merely's ROBLOX Tablet",
					description = "Winner: Merely. ROBLOX will be in touch to redeem this prize.",
					enableComments = false,
					isCopyingAllowed = false,
			   }
			end

			return HttpService:JSONEncode(result)
		end,
	}

	--parse the url
	local endpoint = getEndpoint(requestOptions.Url)
	local args = getArgs(requestOptions.Url)
	local responseFunc = responses[endpoint] or function()
		return HttpService:JSONEncode({
			data = {
			}
		})
	end

	return {
		Body = responseFunc(args),
		Success = true,
		StatusMessage = "OK",
		StatusCode = 200,
	}
end

return mockNetworkLayer