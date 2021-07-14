local root = script.Parent
local Cryo = require(root.Cryo)

local UriIds = {}
UriIds.__index = UriIds

function UriIds:new(ids, delimiter)
	return setmetatable({
		ids = UriIds.makeArray(ids),
		delimiter = delimiter
	}, self)
end

function UriIds:setIds(ids)
	self.ids = UriIds.makeArray(ids)
end

function UriIds.makeArray(ids)
	if type(ids) == "table" then
		return ids
	end
	return {ids}
end

function UriIds:__tostring()
	return table.concat(self.ids, self.delimiter)
end

local RequestBuilder = {}
RequestBuilder.__index = RequestBuilder

function RequestBuilder:new(baseUrl)
	return setmetatable({
		baseUrl = baseUrl,
		keyMapper = nil,
		args = {},
		pathElements = {},
		configurableIds = nil,
		namedIds = {},
		idsDelimiter = ",",
		options = {
			queryArgs = nil,
			postBody = nil,
		},
		useExpandedForm = {},
	}, self)
end

function RequestBuilder:path(path)
	table.insert(self.pathElements, path)
	return self
end

function RequestBuilder:id(ids, key)
	if not key and #self.pathElements < 1 then
		warn("Cannot name id or ids because there is no leading path segment and no name is provided")
	end
	local name = key or self.pathElements[#self.pathElements]
	self.namedIds[name] = ids

	self.configurableIds = UriIds:new(ids, self.idsDelimiter)
	table.insert(self.pathElements, self.configurableIds)
	return self
end

function RequestBuilder:queryArgWithIds(argName, ids)
	local combinedIds = Cryo.List.join(ids, self.namedIds[argName] or {})
	self.namedIds[argName] = combinedIds
	self.configurableIds = UriIds:new(combinedIds, self.idsDelimiter)
	self.args = Cryo.Dictionary.join(self.args, {
		[argName] = self.configurableIds
	})
	return self
end

function RequestBuilder:expandedQueryArgsWithIds(argName, ids)
	self.useExpandedForm[argName] = true
	self:queryArgWithIds(argName, ids)
	return self
end

function RequestBuilder:queryArgs(args)
	self.args = Cryo.Dictionary.join(self.args, args)
	self.options.queryArgs = Cryo.Dictionary.join(args, self.options.queryArgs or {})
	return self
end

function RequestBuilder:body(dictionary)
	self.options.postBody = dictionary
	return self
end

function RequestBuilder:makeKeyMapper()
	return function(someId)
		return self:makeUrl(someId)
	end
end

function RequestBuilder:makeUri()
	local fullPath = ""
	for _, element in ipairs(self.pathElements) do
		fullPath = fullPath .. "/" .. tostring(element)
	end
	return fullPath
end

local function concatArguments(argsString, argName, argIds, useExpandedForm)
	if useExpandedForm then
		for _, id in pairs(argIds.ids) do
			argsString = concatArguments(argsString, argName, id)
		end
	else
		local arg = tostring(argName) .. "=" .. tostring(argIds)
		if argsString:len() > 1 then
			argsString = argsString .. "&" .. arg
		else
			argsString = arg
		end
	end

	return argsString
end

function RequestBuilder:makeQueryArgs(ids)
	self:_plugInConfigurableIds(ids)
	local argsString = ""
	for argName, argIds in pairs(self.args) do
		argsString = concatArguments(argsString, argName, argIds, self.useExpandedForm[argName])
	end
	if argsString:len() > 1 then
		return "?" .. argsString
	end
	return ""
end

function RequestBuilder:makeUrl(ids)
	self:_plugInConfigurableIds(ids)
	local fullUrl = self.baseUrl .. self:makeUri() .. self:makeQueryArgs(ids)
	return fullUrl
end

function RequestBuilder:makeOptions()
	return self.options
end

function RequestBuilder:_plugInConfigurableIds(ids)
	if ids ~= nil and self.configurableIds then
		self.configurableIds:setIds(ids)
	end
end

function RequestBuilder:getIds()
	if self.configurableIds and self.configurableIds.ids then
		return self.configurableIds.ids
	end
	return {}
end

function RequestBuilder:getNamedIds()
	return self.namedIds
end

return RequestBuilder
