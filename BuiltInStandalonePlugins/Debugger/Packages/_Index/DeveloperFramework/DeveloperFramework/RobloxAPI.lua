--[[
	RobloxAPI is a single source of truth for interacting with all of our network endpoints.
	Whenever a new endpoint is implemented, it can be added here and all other code can benefit from it.

	Props :
		networking - (Networking, optional) an object that returns promises when you call http functions

	Functions:
		function RobloxAPI.new(optional table props):
			Constructs an object

	Usage :
		-- create a thunk for fetching information about plugins
		local Packages = script.Parent.Parent.Parent.Packages
		local DevFramework = Packages.DevFramework
		local RobloxAPI = require(DevFramework.RobloxAPI)
		local API = RobloxAPI.new()

		local fetchPromise = API.Develop.V1.plugins({ 123, 456 }):makeRequest()

		-- parse the response and handle any errors
		fetchPromise:andThen(function(response)
			local json = response.responseBody
			for k, v in pairs(json) do
				print(k, v)
			end
		end, function(err)
			print("Could not fetch information for ", assetId)
		end)
]]
local DevFrameworkRoot = script.Parent
local Url = require(script.Url)
local Networking = require(DevFrameworkRoot.Http).Networking
-- TODO: jbousellam - 3/16/21 - remove with FFlagStudioCreatePluginPolicyService
local StudioService = game:GetService("StudioService")

local strict = require(DevFrameworkRoot.Util.strict)

-- helper functions
-- dir : (Instance) a Folder to dig through
-- ... : (Variant) any number of arguments to initialize the children with
local function initDirectoryWithArgs(dir, networkingImpl, baseUrl)
	--[[
		When pointed at an Instance, will recurse through the children to initialize
		all of the required elements with the arguments supplied to this function.

		Returns an initialized table representation of the directory structure.
	]]
	assert(dir:IsA("Instance"), "dir is expected to be an Instance")
	local childrenMap = {}
	for _, child in ipairs(dir:GetChildren()) do
		if child.ClassName == "Folder" then
			childrenMap[child.Name] = initDirectoryWithArgs(child, networkingImpl, baseUrl)

		elseif child.ClassName == "ModuleScript" then
			local targetFunction = require(child)
			childrenMap[child.Name] = targetFunction(networkingImpl, baseUrl)

		else
			warn(string.format("Unexpected object found when constructing children table : %s", child:GetFullName()))
		end
	end

	if next(childrenMap) == nil then
		warn(string.format("Could not find any children for %s", dir:GetFullName()))
	end

	return strict(childrenMap)
end

local RobloxAPI = {}
RobloxAPI.__index = RobloxAPI

-- props : (table, optional)
-- props.networking : (Http.Networking, optional) a promised-based http implementation
-- props.baseUrl : (Url, optional) a container that holds all of the Roblox domains
function RobloxAPI.new(props)
	if not props then
		props = {}
	end

	local networkingImpl = props.networking
	if not networkingImpl then
		networkingImpl = Networking.new({
			isInternal = true,
		})
	end

	local baseUrl = props.baseUrl
	if not baseUrl then
		baseUrl = Url.new()
	end

	-- construct the full API table
	local robloxApi = {
		_baseUrls = baseUrl,
		APIS = initDirectoryWithArgs(script.APIS, networkingImpl, baseUrl),
		API = initDirectoryWithArgs(script.API, networkingImpl, baseUrl),
		AssetGame = initDirectoryWithArgs(script.AssetGame, networkingImpl, baseUrl),
		Catalog = initDirectoryWithArgs(script.Catalog, networkingImpl, baseUrl),
		GameInternationalization = initDirectoryWithArgs(
			script.GameInternationalization, networkingImpl, baseUrl),
		Locale = initDirectoryWithArgs(script.Locale, networkingImpl, baseUrl),
		LocalizationTables = initDirectoryWithArgs(script.LocalizationTables, networkingImpl, baseUrl),
		Develop = initDirectoryWithArgs(script.Develop, networkingImpl, baseUrl),
		TranslationRoles = initDirectoryWithArgs(script.TranslationRoles, networkingImpl, baseUrl),
		WWW = initDirectoryWithArgs(script.WWW, networkingImpl, baseUrl),
		ToolboxService = initDirectoryWithArgs(script.ToolboxService, networkingImpl, baseUrl),
		-- add more endpoint domains here
	}
	setmetatable(robloxApi, RobloxAPI)

	return robloxApi
end

local isCli, _ = pcall(function()
	game:GetService("ProcessService")
end)

-- TODO: jbousellam - 3/16/21 - remove with FFlagStudioCreatePluginPolicyService
function RobloxAPI:baseURLHasChineseHost()
	if isCli then
		return false
	else
		return StudioService:BaseURLHasChineseHost()
	end
end

return RobloxAPI
