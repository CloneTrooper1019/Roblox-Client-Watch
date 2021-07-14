local FFlagTerrainToolsImportUploadAssets = game:GetFastFlag("TerrainToolsImportUploadAssets")

local Plugin = script.Parent.Parent.Parent


local Framework = require(Plugin.Packages.Framework)
local Cryo = require(Plugin.Packages.Cryo)
local Roact = require(Plugin.Packages.Roact)

local ContextItem = Framework.ContextServices.ContextItem
local Provider = Framework.ContextServices.Provider

local FrameworkUtil = Framework.Util
local Signal = FrameworkUtil.Signal
local Promise = FrameworkUtil.Promise

local Constants = require(Plugin.Src.Util.Constants)
local ImportAssetHandler = require(Plugin.Src.Util.ImportAssetHandler)

local TerrainEnums = require(Plugin.Src.Util.TerrainEnums)
local ImportMaterialMode = TerrainEnums.ImportMaterialMode

local HeightmapImporterService = game:GetService("HeightmapImporterService")
-- Importing HttpService only for GenerateGUID
local HttpService = game:GetService("HttpService")

--[[
Returns `true` if valid, else `false, warningString` to be logged
]]
local function validateImportSettingsOrWarn(importSettings, DEPRECATED_localization)
	if not (importSettings.heightmap and importSettings.heightmap.file) then
		return false, "ValidHeightMapImport"
	end

	if importSettings.materialMode == ImportMaterialMode.Colormap
		and not (importSettings.colormap and importSettings.colormap.file) then
		return false, "NoColormapProvided"
	end

	return true
end

local TerrainImporter = ContextItem:extend("TerrainImporter")

function TerrainImporter.new(options)
	assert(options and type(options) == "table", "TerrainImporter requires an options table")

	local self = setmetatable({
		_localization = options.localization,
		_analytics = options.analytics,
		_assetHandler = FFlagTerrainToolsImportUploadAssets
			and ImportAssetHandler.new(options.imageUploader, nil, options.userId)
			or nil,
		_heightmapImporterService = options.heightmapImporterService or HeightmapImporterService,

		_importSettings = {
			guid = nil,

			position = Vector3.new(0, 0, 0),
			size = Vector3.new(0, 0, 0),

			heightmap = nil,
			colormap = nil,
			defaultMaterial = Enum.Material.Asphalt,
			materialMode = ImportMaterialMode.DefaultMaterial,
		},

		_importing = false,
		_importProgress = 0,
		_importOperation = "",

		_isPaused = false,
		_hasPixelWarning = false,

		_updateSignal = Signal.new(),
		_errorSignal = Signal.new(),
		_importFinishSignal = Signal.new(),

	}, TerrainImporter)

	assert(self._heightmapImporterService, "TerrainImporter.new() requires a HeightmapImporterService")

	self._updateImportProgress = function(completionPercent, operation)
		self._importProgress = completionPercent
		self._importOperation = operation
		self._updateSignal:Fire()
	end

	self._terrainProgressUpdateConnection = self._heightmapImporterService.ProgressUpdate:Connect(
		self._updateImportProgress)

	self._heightmapImporterService.ColormapHasUnknownPixels:Connect(function()
		self._hasPixelWarning = true
	end)

	return self
end

function TerrainImporter:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
		UpdateSignal = self._updateSignal,
	}, {root})
end

function TerrainImporter:subscribeToImportFinish(callback)
	return self._importFinishSignal:Connect(callback)
end

function TerrainImporter:subscribeToErrors(callback)
	return self._errorSignal:Connect(callback)
end

function TerrainImporter:getHasPixelWarning()
	return self._hasPixelWarning
end

function TerrainImporter:clearHasPixelWarning()
	self._hasPixelWarning = false
end

function TerrainImporter:getImportProgress()
	return self._importProgress
end

function TerrainImporter:getImportOperation()
	return self._importOperation
end

function TerrainImporter:isImporting()
	return self._importing
end

function TerrainImporter:isPaused()
	return self._isPaused
end

function TerrainImporter:destroy()
	self:_setImporting(false)

	self._heightmapImporterService = nil
	self._localization = nil
	self._analytics = nil
	self._imageUploader = nil
end

function TerrainImporter:updateSettings(newSettings)
	self._importSettings = Cryo.Dictionary.join(self._importSettings, newSettings)
end

function TerrainImporter:_setImporting(importing)
	if importing ~= self._importing then
		self._importing = importing
		self._isPaused = false
		self._updateSignal:Fire()
	end
end

function TerrainImporter:togglePause()
	self._isPaused = not self._isPaused
	self._heightmapImporterService:SetImportHeightmapPaused(self._isPaused)
	self._updateSignal:Fire()
end

function TerrainImporter:cancel()
	self._heightmapImporterService:CancelImportHeightmap()
	self._hasPixelWarning = false
end

local function doImport(heightmapImporterService, importSettings, updateProgress, localization, analytics, assetHandler)
	-- Copy the settings we're using in case they change during the import
	importSettings = Cryo.Dictionary.join(importSettings, {})

	return Promise.new(function(resolve, reject)
		local success, err = validateImportSettingsOrWarn(importSettings)
		if not success then
			reject(localization:getText("Warning", err))
			return
		end

		local size = importSettings.size
		local center = importSettings.position or Vector3.new(0, 0, 0)
		center = center + Vector3.new(0, size.Y / 2, 0)

		local offset = size / 2
		local regionStart = center - offset
		local regionEnd = center + offset
		local region = Region3.new(regionStart, regionEnd):ExpandToGrid(Constants.VOXEL_RESOLUTION)

		local heightmapUrl = importSettings.heightmap.file:GetTemporaryId()

		local materialMode = importSettings.materialMode
		local colormapUrl = ""
		local defaultMaterial = Enum.Material.Asphalt

		if materialMode == ImportMaterialMode.DefaultMaterial then
			defaultMaterial = importSettings.defaultMaterial
		elseif materialMode == ImportMaterialMode.Colormap then
			colormapUrl = importSettings.colormap.file:GetTemporaryId()
		end

		if analytics then
			local material = "Colormap"
			local colormapData = {}
			if (materialMode == ImportMaterialMode.DefaultMaterial) then
				material =  importSettings.defaultMaterial.Name
			else
				colormapData = {
					width = importSettings.colormap.width,
					height = importSettings.colormap.height,
					channels = importSettings.colormap.channels,
				}
			end

			local heightmapData = {
				width = importSettings.heightmap.width,
				height = importSettings.heightmap.height,
				channels = importSettings.heightmap.channels,
			}

			analytics:report("importTerrainLocal", region, material, heightmapData, colormapData, importSettings.guid)
		end

		if FFlagTerrainToolsImportUploadAssets then
			-- Spawn this before calling ImportHeightmap() as that blocks until the import has entirely finished
			spawn(function()
				assetHandler:handleAsset(importSettings.heightmap.file, region,
					importSettings.guid and function(assetId)
						analytics:report("importTerrainLocalHeightMap", assetId, importSettings.guid)
					end or nil)

				local handleColormap = materialMode == ImportMaterialMode.Colormap and importSettings.colormap.file
				if handleColormap then
					assetHandler:handleAsset(importSettings.colormap.file, region,
						importSettings.guid and function(assetId)
							analytics:report("importTerrainLocalColorMap", assetId, importSettings.guid)
						end or nil)
				end
			end)
		end

		success, err = pcall(function()
			heightmapImporterService:ImportHeightmap(region, heightmapUrl, colormapUrl, defaultMaterial)
		end)

		if not success then
			reject(err)
			return
		end

		resolve()
	end)
end

function TerrainImporter:startImport()
	if self._importing then
		return
	end

	if FFlagTerrainToolsImportUploadAssets then
		self:updateSettings({
			guid = HttpService:GenerateGUID(),
		})
	end

	local function beginImport()
		self._hasPixelWarning = false
		self._updateImportProgress(0, "Starting")
		self:_setImporting(true)
	end

	local function finishImport()
		self._updateImportProgress(1, "")
		self:_setImporting(false)
		self._importFinishSignal:Fire()
	end

	local function handleFailure(message)
		self._errorSignal:Fire(message)
	end

	beginImport()
	doImport(self._heightmapImporterService, self._importSettings, self._updateImportProgress,
		self._localization, self._analytics, self._assetHandler)
		:catch(handleFailure)
		:await()
	finishImport()
end

return TerrainImporter
