local Plugin = script.Parent.Parent.Parent

local Url = require(Plugin.Packages.Framework).Url

local DATA_URL = Url.new().DATA_URL

local function makeUploadRequest(networking, name, description, contents)
	local url = Url.composeUrl(DATA_URL, "ide/publish/UploadNewImage", {
		name = name or "",
		description = description or "",
	})

	local headers = {
		["Content-Type"] = "multipart/form-data; boundary=EA0A21C3-8388-4038-9BD5-92C8B1B7BF8E",
	}

	local payload = contents

	return networking:post(url, payload, headers)
end

local ImageUploader = {}
ImageUploader.__index = ImageUploader

function ImageUploader.new(networking)
	local self = {
		_networking = networking,
		_promises = {},
	}

	assert(self._networking, "ImageUploader requires a Networking instance")

	setmetatable(self, ImageUploader)

	return self
end

function ImageUploader:destroy()
	self._networking = nil
	self._promises = {}
end

--[[
Params
	string tempId
		The temporary ID of the asset in the form of rbxtemp://xyz
	string name
		The name of the uploaded asset
	string? description
		Description to upload with the asset. Optional, defaults to empty string
	string contents
		The contents of the asset being uploaded

Returns
	Promise
		If upload was successful, returns the new asset id of the uploaded asset
		If upload failed, returns the error struct
]]
function ImageUploader:upload(tempId, name, description, contents)
	assert(type(tempId) == "string", "ImageUploader:upload() expects tempId to be a string")
	assert(type(name) == "string", "ImageUploader:upload() expects name to be a string")
	assert(type(description) == "string" or type(description) == "nil",
		"ImageUploader:upload() expects description to be a string or nil")
	assert(type(contents) == "string", "ImageUploader:upload() expects contents to be a string")

	description = description or ""

	-- We've already started a request for this upload
	-- Just reuse it
	if self._promises[tempId] then
		return self._promises[tempId]
	end

	local request = makeUploadRequest(self._networking, name, description, contents)

	-- Pull the new asset id out of the response before passing it on to consumers
	request = request:andThen(function(result)
		return result.responseBody
	end)

	self._promises[tempId] = request

	return request
end

return ImageUploader
