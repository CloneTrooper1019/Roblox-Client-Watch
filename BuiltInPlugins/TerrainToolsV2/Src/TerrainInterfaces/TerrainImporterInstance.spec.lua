local Plugin = script.Parent.Parent.Parent
local TestHelpers = Plugin.Src.TestHelpers

local MockHeightmapImporterService = require(TestHelpers.MockHeightmapImporterService)
local MockTerrain = require(TestHelpers.MockTerrain)

local TerrainImporter = require(script.Parent.TerrainImporterInstance)

local EMPTY_USERID = 0

return function()
	local heightmapImporterService = MockHeightmapImporterService.new()
	local terrain = MockTerrain.new()

	it("should be creatable", function()
		expect(TerrainImporter.new({
			terrain = terrain,
			imageUploader = {},
			heightmapImporterService = heightmapImporterService,
			userId = EMPTY_USERID,
		})).to.be.ok()
	end)

	it("should require an options table", function()
		expect(function()
			TerrainImporter.new(nil)
		end).to.throw()
	end)

	if game:GetFastFlag("TerrainToolsImportUploadAssets") then
		it("should require an ImageUploader instance", function()
			expect(function()
				TerrainImporter.new({
					terrain = terrain,
					heightmapImporterService = heightmapImporterService,
					userId = EMPTY_USERID,
				})
			end).to.throw()
		end)
	end
end
