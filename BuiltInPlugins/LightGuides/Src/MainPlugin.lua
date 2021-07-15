local Plugin = script.Parent.Parent

local Types = require(Plugin.Src.Types)

local getFIntStudioLightGuideMaxPoolSize = require(Plugin.Src.Flags.getFIntStudioLightGuideMaxPoolSize)

local Utility = Plugin.Src.Utility
local SphereWireframe = require(Utility.SphereWireframe)
local ConeWireframe = require(Utility.ConeWireframe)
local TrapezoidalPrismWireframe = require(Utility.TrapezoidalPrismWireframe)
local isProtectedInstance = require(Utility.isProtectedInstance)

-- These strings match the class name of their corresponding lights
local LIGHT_TYPE = {
	PointLight = "PointLight",
	SpotLight = "SpotLight",
	SurfaceLight = "SurfaceLight"
}

type LightType = string

local WIREFRAME_CONSTRUCTORS = {
	[LIGHT_TYPE.PointLight] = SphereWireframe.new,
	[LIGHT_TYPE.SpotLight] = ConeWireframe.new,
	[LIGHT_TYPE.SurfaceLight] = TrapezoidalPrismWireframe.new,
}

local FIntStudioLightGuideMaxPoolSize = getFIntStudioLightGuideMaxPoolSize()

local Selection = game:GetService("Selection")
local CoreGui = game:GetService("CoreGui")

local function createWireframeForLight(lightType, instance, target)
	assert(
		WIREFRAME_CONSTRUCTORS[lightType],
		string.format(
			"Light type %s needs to be associated with a corresponding wireframe",
			lightType
		)
	)
	local wireframe = WIREFRAME_CONSTRUCTORS[lightType]()
	wireframe:setGuidesFolder(target)
	wireframe:adorn(instance)
	wireframe:setHandles()
	return wireframe
end

type _mainPlugin = {
	_folder: Instance,
	_wireframePools: Types.Map<LightType, Types.Array<any>>,
	_wireframes: Types.Map<Instance, any>,
	_storedLightGuides: number,
	_listener: RBXScriptConnection,
}

local MainPlugin = {}
MainPlugin.__index = MainPlugin

function MainPlugin.new()
	local self: _mainPlugin = {
		_folder = CoreGui:FindFirstChild("LightGuides"),
		_wireframePools = {
			[LIGHT_TYPE.PointLight] = {},
			[LIGHT_TYPE.SpotLight] = {},
			[LIGHT_TYPE.SurfaceLight] = {},
		},
		_wireframes = {},
		_storedLightGuides = 0,
		_listener = nil,
	}

	if not self._folder then
		self._folder = Instance.new("Folder")
		self._folder.Name = "LightGuides"
		self._folder.Parent = CoreGui
	end

	setmetatable(self, MainPlugin)

	self._listener = Selection.SelectionChanged:Connect(function()
		self:renderSelection()
	end)

	return self
end

function MainPlugin:renderSelection()
	local reselectedLights: Types.Map<Light, any> = {}
	local newlySelectedLights: Types.Map<Light, LightType> = {}

	-- Carry over same selection to new selection
	for _, instance in ipairs(Selection:Get()) do
		if isProtectedInstance(instance) or not instance:IsA("Light") then
			continue
		end

		if self._wireframes[instance] then
			reselectedLights[instance] = self._wireframes[instance]
			self._wireframes[instance] = nil
		else
			newlySelectedLights[instance] = instance.ClassName :: LightType
		end
	end

	-- Add unused wireframes to pools for reuse
	for instance, wireframe in pairs(self._wireframes) do
		local lightType: string = instance.ClassName

		assert(
			self._wireframePools[lightType],
			string.format(
				"Light type %s needs to be associated with a corresponding wireframe",
				lightType
			)
		)

		table.insert(self._wireframePools[lightType], wireframe:pool())
		self._storedLightGuides += 1
		self._wireframes[instance] = nil
	end

	for instance, lightType in pairs(newlySelectedLights) do
		local size = #self._wireframePools[lightType]
		if size >= 1 then
			-- Grab from corresponding pool if available
			reselectedLights[instance] = self._wireframePools[lightType][size]:adorn(instance)
			self._wireframePools[lightType][size] = nil
			self._storedLightGuides -= 1
		else
			if #self._wireframes + self._storedLightGuides >= FIntStudioLightGuideMaxPoolSize then
				-- If max inactive + active lights, remove from other pool
				for _, lightPool in pairs(self._wireframePools) do
					if #lightPool > 0 then
						lightPool[#lightPool]:destroy()
						lightPool[#lightPool] = nil
						break
					end
				end
			end

			-- Create new wireframe
			reselectedLights[instance] = createWireframeForLight(lightType, instance, self._folder)
		end
		reselectedLights[instance]:render()
	end

	self._wireframes = reselectedLights
end

function MainPlugin:emptyPools()
	for _, pool in pairs(self._wireframePools) do
		for _, light in pairs(pool) do
			light:destroy()
		end
	end
end

function MainPlugin:emptyWireframes()
	for _, wireframe in pairs(self._wireframes) do
		wireframe:destroy()
	end
end

function MainPlugin:destroy()
	self:emptyWireframes()
	self:emptyPools()

	self._wireframes = nil
	self._wireframePools = nil

	self._folder:Destroy()

	self._listener:Disconnect()
end

return MainPlugin
