local UnvalidatedAssetService = game:GetService("UnvalidatedAssetService")

local ImportAssetHandler = require(script.Parent.ImportAssetHandler)

local EMPTY_USERID = 0

return function()
	local function createAssetFile(id, name, contents)
		return {
			Name = name,
			GetTemporaryId = function()
				return id
			end,
			GetBinaryContents = function()
				return contents
			end,
		}
	end

	it("should be creatable", function()
		local imageUploader = {}
		local importAssetHandler = ImportAssetHandler.new(imageUploader, UnvalidatedAssetService, EMPTY_USERID)
		expect(importAssetHandler).to.be.ok()
	end)

	it("should expect an ImageUploader instance", function()
		expect(function()
			ImportAssetHandler.new(nil, UnvalidatedAssetService, EMPTY_USERID)
		end).to.throw()
	end)

	describe("handleAsset", function()
		it("should expect an AssetFile instance", function()
			local imageUploader = {}
			local importAssetHandler = ImportAssetHandler.new(imageUploader, UnvalidatedAssetService, EMPTY_USERID)
			expect(function()
				importAssetHandler:handleAsset()
			end).to.throw()
		end)

		it("should expect a region", function()
			local imageUploader = {}
			local importAssetHandler = ImportAssetHandler.new(imageUploader, UnvalidatedAssetService, EMPTY_USERID)
			expect(function()
				local assetFile = {}
				importAssetHandler:handleAsset(assetFile)
			end).to.throw()
		end)

		it("should expect temp id to be the right format", function()
			local imageUploader = {}
			local importAssetHandler = ImportAssetHandler.new(imageUploader, UnvalidatedAssetService, EMPTY_USERID)

			expect(function()
				local assetFile = createAssetFile("foo")
				local region = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
				importAssetHandler:handleAsset(assetFile, region)
			end).to.throw()
		end)

		it("should call AppendTempAssetId", function()
			local appendTempAssetIdCalled = false

			local imageUploader = {
				upload = function()
					-- Fake a promise
					return {
						andThen = function() end,
					}
				end,
			}

			local unvalidatedAssetService = {
				AppendTempAssetId = function(self, userId, tempIdNumber, lookAt, cameraPos, usage)
					expect(userId).to.equal(1234567890)
					expect(tempIdNumber).to.equal(1234)
					expect(lookAt).to.be.ok()
					expect(cameraPos).to.be.ok()
					expect(usage).to.be.ok()

					appendTempAssetIdCalled = true
				end
			}

			local importAssetHandler = ImportAssetHandler.new(imageUploader, unvalidatedAssetService, 1234567890)

			local assetFile = createAssetFile("rbxtemp://1234", "", "")
			local region = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
			importAssetHandler:handleAsset(assetFile, region)

			expect(appendTempAssetIdCalled).to.equal(true)
		end)

		it("should pass the asset data to image uploader", function()
			local imageUploadCalled = false

			local imageUploader = {
				upload = function(self, tempId, name, description, contents)
					expect(tempId).to.equal("rbxtemp://1234")
					expect(name).to.equal("AssetNameHere")
					expect(description).to.be.ok()
					expect(contents).to.equal("SomeAssetContents")

					imageUploadCalled = true

					return {
						andThen = function() end,
					}
				end,
			}

			local unvalidatedAssetService = {
				AppendTempAssetId = function() end,
			}

			local importAssetHandler = ImportAssetHandler.new(imageUploader, unvalidatedAssetService, 0)

			local assetFile = createAssetFile("rbxtemp://1234", "AssetNameHere", "SomeAssetContents")
			local region = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
			importAssetHandler:handleAsset(assetFile, region)

			expect(imageUploadCalled).to.equal(true)
		end)

		it("should call UpgradeTempAssetId on upload resolve", function()
			local upgradeTempAssetIdCalled = false

			local assetIdToReturn

			local imageUploader = {
				upload = function()
					return {
						andThen = function(self, resolve, reject)
							resolve(assetIdToReturn)
						end,
					}
				end,
			}

			local unvalidatedAssetService = {
				AppendTempAssetId = function() end,
				UpgradeTempAssetId = function(self, userId, tempId, assetId)
					expect(userId).to.equal(1234567890)
					expect(tempId).to.equal(1234)
					expect(assetId).to.equal(5678)
					upgradeTempAssetIdCalled = true
				end,
			}

			local importAssetHandler = ImportAssetHandler.new(imageUploader, unvalidatedAssetService, 1234567890)

			local region = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))

			-- Check that if the asset id we get from the web isn't valid, we don't call into UnvalidatedAssetService
			assetIdToReturn = "foo"
			expect(function()
				importAssetHandler:handleAsset(createAssetFile("rbxtemp://1", "", ""), region)
			end).to.throw()
			expect(upgradeTempAssetIdCalled).to.equal(false)

			-- Try again with a proper asset id
			assetIdToReturn = "5678"
			importAssetHandler:handleAsset(createAssetFile("rbxtemp://1234", "", ""), region)
			expect(upgradeTempAssetIdCalled).to.equal(true)
		end)

		it("should call AppendVantagePoint on asset reuse", function()
			local appendVantagePointCalled = false

			local imageUploader = {
				upload = function()
					return {
						andThen = function(self, resolve, reject)
							resolve("5678")
						end,
					}
				end,
			}

			local unvalidatedAssetService = {
				AppendTempAssetId = function() end,
				UpgradeTempAssetId = function() end,
				AppendVantagePoint = function(self, userId, assetId, lookAt, cameraPos)
					expect(userId).to.equal(1234567890)
					expect(assetId).to.equal(5678)
					expect(lookAt).to.be.ok()
					expect(cameraPos).to.be.ok()
					appendVantagePointCalled = true
				end,
			}

			local importAssetHandler = ImportAssetHandler.new(imageUploader, unvalidatedAssetService, 1234567890)

			local assetFile = createAssetFile("rbxtemp://1234", "", "")
			local firstRegion = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
			local secondRegion = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))

			importAssetHandler:handleAsset(assetFile, firstRegion)
			expect(appendVantagePointCalled).to.equal(false)
			importAssetHandler:handleAsset(assetFile, secondRegion)
			expect(appendVantagePointCalled).to.equal(true)
		end)

		it("should handle reusing an asset before the upload finishes", function()
			--[[
				In a sequence of events like:
					Use asset
					Upload asset
					Use asset again in another location
					Asset upload returns
					Use asset a third time
				We need to make that sure that all 3 uses of the asset are tracked correctly
				Even though some of the uses are before having the real id, and some are after
			]]

			local vantagePoints = {}

			local resolves = {}
			local imageUploader = {
				upload = function()
					return {
						andThen = function(self, resolve, reject)
							table.insert(resolves, resolve)
						end,
					}
				end,
			}

			local unvalidatedAssetService = {
				AppendTempAssetId = function(self, userId, tempId, lookAt, cameraPos, usage)
					expect(vantagePoints[tempId]).to.never.be.ok()
					vantagePoints[tempId] = {usage = usage, points = {}}
					table.insert(vantagePoints[tempId].points, {lookAt, cameraPos})
				end,
				UpgradeTempAssetId = function(self, userId, tempId, assetId)
					expect(vantagePoints[tempId]).to.be.ok()
					expect(vantagePoints[assetId]).to.never.be.ok()
					vantagePoints[assetId] = vantagePoints[tempId]
					vantagePoints[tempId] = nil
				end,
				AppendVantagePoint = function(self, userId, assetId, lookAt, cameraPos)
					expect(vantagePoints[assetId]).to.be.ok()
					table.insert(vantagePoints[assetId].points, {lookAt, cameraPos})
				end,
			}

			local importAssetHandler = ImportAssetHandler.new(imageUploader, unvalidatedAssetService, 1234567890)

			local assetFile = createAssetFile("rbxtemp://1234", "", "")
			local firstRegion = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
			local secondRegion = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))
			local thirdRegion = Region3.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))

			importAssetHandler:handleAsset(assetFile, firstRegion)
			importAssetHandler:handleAsset(assetFile, secondRegion)

			for _, resolve in ipairs(resolves) do
				resolve("5678")
			end
			resolves = {}

			expect(vantagePoints[1234]).to.never.be.ok()
			expect(vantagePoints[5678]).to.be.ok()
			expect(#vantagePoints[5678].points).to.equal(2)

			importAssetHandler:handleAsset(assetFile, thirdRegion)
			for _, resolve in ipairs(resolves) do
				resolve("5678")
			end
			resolves = {}

			expect(vantagePoints[1234]).to.never.be.ok()
			expect(vantagePoints[5678]).to.be.ok()
			expect(#vantagePoints[5678].points).to.equal(3)
		end)
	end)
end
