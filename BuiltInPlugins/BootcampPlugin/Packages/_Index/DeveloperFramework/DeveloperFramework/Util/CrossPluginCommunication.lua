--[[
	Wrapper for cross-plugin communication between BuiltIn plugins.

	This wrapper assumes that the plugins share a data model, so is not suitable for the Standalone <-> Built-In case.
]]

local RobloxPluginGuiService = game:GetService("RobloxPluginGuiService")

local t = require(script.Parent.Typecheck.t)

local function findFirstChildOfNameAndType(parent, name, type)
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA(type) and child.Name == name then
			return child
		end
	end
	return nil
end

local CrossPluginCommunication = {}
CrossPluginCommunication.__index = CrossPluginCommunication

CrossPluginCommunication.BASE_FOLDER_NAME = "CrossPluginCommunication"

function CrossPluginCommunication.new(pluginNamespace, hostService)
	assert(t.string(pluginNamespace), "pluginNamespace must be a string")
	assert(t.optional(t.instance(pluginNamespace)), "hostService must be an instance if defined")

	local self = {
		hostService = hostService or RobloxPluginGuiService,
		pluginNamespace = pluginNamespace
	}

	return setmetatable(self, CrossPluginCommunication)
end

function CrossPluginCommunication:cleanup()
	self:getNamespaceFolder():Destroy()
end

function CrossPluginCommunication:ensureFolderExists(parent, name)
	local folder = findFirstChildOfNameAndType(parent, name, "Folder")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end

	return folder
end

function CrossPluginCommunication:getNamespaceFolder()
	local base = self:ensureFolderExists(self.hostService, self.BASE_FOLDER_NAME)

	return self:ensureFolderExists(base, self.pluginNamespace)
end

function CrossPluginCommunication:getFunction(name)
	assert(t.string(name), "name must be a string")

	local folder = self:getNamespaceFolder()

	local func = findFirstChildOfNameAndType(folder, name, "BindableFunction")

	if not func then
		error("No function named " .. name .. " exists")
	end

	return func
end

function CrossPluginCommunication:createFunction(name)
	assert(t.string(name), "name must be a string")

	local folder = self:getNamespaceFolder()

	local func = folder:FindFirstChild(name)

	if func then
		error(func:GetFullName() .. " already exists")
	end

	func = Instance.new("BindableFunction")
	func.Name = name
	func.Parent = folder

	return func
end

function CrossPluginCommunication:Invoke(name, ...)
	assert(t.string(name), "name must be a string")

	local func = self:getFunction(name)

	return func:Invoke(...)
end

function CrossPluginCommunication:OnInvoke(name, callback)
	assert(t.string(name), "name must be a string")
	assert(t.callback(callback), "callback must be a function")

	local func = self:createFunction(name)

	func.OnInvoke = callback
end

return CrossPluginCommunication