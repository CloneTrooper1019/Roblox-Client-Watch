return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Rodux = require(Plugin.Libs.Rodux)
	local NetworkInterfaceMock = require(Plugin.Core.Networking.NetworkInterfaceMock)
	local GetOverrideAssetRequest = require(Plugin.Core.Networking.Requests.GetOverrideAssetRequest)
	local AssetConfigReducer = require(Plugin.Core.Reducers.AssetConfigReducer)
	
	it("should fetch multiple pages even if there is a page with no results but a valid cursor", function()
		local assetTypeEnum = Enum.AssetType.Model.Value
		local creatorType = Enum.CreatorType.User.Value
		local creatorId = 1
		local targetPage = 1
		local networkInterfaceMock = NetworkInterfaceMock.new()
		local stubCalled

		local store = Rodux.Store.new(AssetConfigReducer, nil, {
		 	Rodux.thunkMiddleware
		})

		-- Page 1
		stubCalled = false
		networkInterfaceMock.getAssetCreations = function(self, pageInfo, cursor, assetTypeOverride, groupIdOverride)
			stubCalled = true
			expect(pageInfo).to.equal(nil)
			expect(cursor).to.equal("")
			expect(assetTypeOverride).to.equal("Model")
			expect(groupIdOverride).to.equal(nil)
			return {
				andThen = function(self, fulfil)
					fulfil({
						responseBody = {
							data = {
								{
									assetId = 1,
									Name = "One"
								}
							},
							nextPageCursor = "page2"
						}
					})
				end,
			}
		end
		store:dispatch(GetOverrideAssetRequest(networkInterfaceMock, assetTypeEnum, creatorType, creatorId, targetPage))
		expect(stubCalled).to.equal(true)
		expect(store:getState().fetchedAll).to.equal(nil)
		expect(store:getState().overrideCursor.nextPageCursor).to.equal("page2")
		targetPage += 1

		-- Page 2
		stubCalled = false
		networkInterfaceMock.getAssetCreations = function(self, pageInfo, cursor, assetTypeOverride, groupIdOverride)
			stubCalled = true
			expect(pageInfo).to.equal(nil)
			expect(cursor).to.equal("page2")
			expect(assetTypeOverride).to.equal("Model")
			expect(groupIdOverride).to.equal(nil)
			return {
				andThen = function(self, fulfil)
					fulfil({
						responseBody = {
							data = {},
							nextPageCursor = "page3"
						}
					})
				end,
			}
		end
		store:dispatch(GetOverrideAssetRequest(networkInterfaceMock, assetTypeEnum, creatorType, creatorId, targetPage))
		expect(stubCalled).to.equal(true)
		expect(store:getState().fetchedAll).to.equal(false)
		expect(store:getState().overrideCursor.nextPageCursor).to.equal("page3")
		targetPage += 1

		-- Page 3
		stubCalled = false
		networkInterfaceMock.getAssetCreations = function(self, pageInfo, cursor, assetTypeOverride, groupIdOverride)
			stubCalled = true
			expect(pageInfo).to.equal(nil)
			expect(cursor).to.equal("page3")
			expect(assetTypeOverride).to.equal("Model")
			expect(groupIdOverride).to.equal(nil)
			return {
				andThen = function(self, fulfil)
					fulfil({
						responseBody = {
							data = {
								{
									assetId = 2,
									Name = "Two"
								}
							}
						}
					})
				end,
			}
		end
		store:dispatch(GetOverrideAssetRequest(networkInterfaceMock, assetTypeEnum, creatorType, creatorId, targetPage))
		expect(stubCalled).to.equal(true)
		expect(store:getState().fetchedAll).to.equal(true)
		expect(store:getState().overrideCursor.nextPageCursor).to.equal("page3")

		expect(#store:getState().resultsArray).to.equal(2)
	end)
end
