local PlayerEmulatorService = game:GetService("PlayerEmulatorService")
local deepEqual = require(game:GetService("CorePackages").tutils :: any).deepEqual

local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)
local TestImmutability = require(Plugin.Src.TestHelpers.testImmutability)
local MockStudioPlugin = require(Plugin.Src.TestHelpers.MockStudioPlugin)
local Constants = require(Plugin.Src.Util.Constants)

local LoadAllPolicyValues = require(Plugin.Src.Actions.LoadAllPolicyValues)
local UpdatePolicySettingStatus = require(Plugin.Src.Actions.UpdatePolicySettingStatus)
local InitPolicySettingStatus = require(Plugin.Src.Thunks.InitPolicySettingStatus)
local UpdatePolicyBooleanItem = require(Plugin.Src.Thunks.UpdatePolicyBooleanItem)
local UpdatePolicyListItem = require(Plugin.Src.Thunks.UpdatePolicyListItem)

local PoliciesReducer = require(Plugin.Src.Reducers.PoliciesReducer)

local mockAllPolicies = {
	BoolItem1 = false,
	BoolItem2 = false,
	ListItem1 = {
		"Hello",
		"World",
	},
	ListItem2 = {
		"Aloha",
	}
}

local mockAllPolicySortedKeys = {
	"BoolItem1",
	"BoolItem2",
	"ListItem1",
	"ListItem2",
}

local mockPolicySettingStatus = {
	BoolItem1 = false,
	BoolItem2 = false,
	ListItem1 = {
		"Hello",
	},
	ListItem2 = {},
}

local mockPolicyApiSetting = {
	BoolItem1 = true,
	BoolItem2 = true,
	ListItem1 = {},
	ListItem2 = {}
}

local mockCachedSetting = {
	BoolItem1 = true,
	BoolItem2 = false,
	ListItem1 = {
		"Hello",
	},
	ListItem2 = {
		"Aloha",
	}
}

return function()
	local function createTestStore(mockData)
		local middlewares = { Rodux.thunkMiddleware }
		local store = Rodux.Store.new(PoliciesReducer, { Policies = mockData }, middlewares)
		return store
	end

	it("should return its expected default state", function()
		local r = Rodux.Store.new(PoliciesReducer)
		expect(r:getState()).to.be.ok()
		expect(type(r:getState().allPolicies)).to.equal("table")
		expect(type(r:getState().allPolicySortedKeys)).to.equal("table")
		expect(type(r:getState().policySettingStatus)).to.equal("table")
	end)

	describe("LoadAllPolicyValues", function()
		it("should set allPolicies and allPolicySortedKeys", function()
			local state = PoliciesReducer(nil, LoadAllPolicyValues(mockAllPolicies, mockAllPolicySortedKeys))
			expect(state.allPolicies).to.be.ok()
			expect(state.allPolicySortedKeys).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.allPolicySortedKeys)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			assert(deepEqual(state.allPolicies, mockAllPolicies))
			assert(deepEqual(state.allPolicySortedKeys, mockAllPolicySortedKeys))
		end)

		it("should preserve immutability", function()
			local immutabilityPreserved = TestImmutability(PoliciesReducer, LoadAllPolicyValues(mockAllPolicies, mockAllPolicySortedKeys))
			expect(immutabilityPreserved).to.equal(true)
		end)
	end)

	describe("UpdatePolicySettingStatus", function()
		it("should update policySettingStatus", function()
			local state = PoliciesReducer(nil, UpdatePolicySettingStatus(mockPolicySettingStatus))
			expect(state.allPolicies).to.be.ok()
			expect(state.allPolicySortedKeys).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.allPolicySortedKeys)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			assert(deepEqual(state.policySettingStatus, mockPolicySettingStatus))
		end)

		it("should preserve immutability", function()
			local immutabilityPreserved = TestImmutability(PoliciesReducer, UpdatePolicySettingStatus(mockPolicySettingStatus))
			expect(immutabilityPreserved).to.equal(true)
		end)
	end)

	describe("InitPolicySettingStatus", function()
		it("should load fallback policy settings when http failed and empty local cache", function()
			local store = createTestStore()
			local mockPlugin = MockStudioPlugin.new()
			store:dispatch(InitPolicySettingStatus(mockAllPolicies, {}, mockPlugin))
			local state = store:getState()
			expect(state.allPolicies).to.be.ok()
			expect(state.allPolicySortedKeys).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.allPolicySortedKeys)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			assert(deepEqual(state.allPolicies, mockAllPolicies))
			assert(deepEqual(state.policySettingStatus, mockAllPolicies))
		end)

		it("should load policy API settings when http succeeded and empty local cache", function()
			local store = createTestStore()
			local mockPlugin = MockStudioPlugin.new()
			store:dispatch(InitPolicySettingStatus(mockAllPolicies, mockPolicyApiSetting, mockPlugin))
			local state = store:getState()
			expect(state.allPolicies).to.be.ok()
			expect(state.allPolicySortedKeys).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.allPolicySortedKeys)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			assert(deepEqual(state.allPolicies, mockAllPolicies))
			assert(deepEqual(state.policySettingStatus, mockPolicyApiSetting))
			assert(deepEqual(PlayerEmulatorService:GetEmulatedPolicyInfo(), mockPolicyApiSetting))
			assert(deepEqual(mockPlugin:GetSetting(Constants.POLICY_SETTING_KEY), mockPolicyApiSetting))
		end)

		it("should load cached settings when http succeeded and has local cache", function()
			local store = createTestStore()
			local mockPlugin = MockStudioPlugin.new(mockCachedSetting)
			store:dispatch(InitPolicySettingStatus(mockAllPolicies, mockPolicyApiSetting, mockPlugin))
			local state = store:getState()
			expect(state.allPolicies).to.be.ok()
			expect(state.allPolicySortedKeys).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.allPolicySortedKeys)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			assert(deepEqual(state.allPolicies, mockAllPolicies))
			assert(deepEqual(state.policySettingStatus, mockCachedSetting))
			assert(deepEqual(PlayerEmulatorService:GetEmulatedPolicyInfo(), mockCachedSetting))
			assert(deepEqual(mockPlugin:GetSetting(Constants.POLICY_SETTING_KEY), mockCachedSetting))
		end)
	end)

	describe("UpdatePolicyBooleanItem", function()
		-- save the orignal value
		local orignalPolicyInfo = PlayerEmulatorService:GetEmulatedPolicyInfo()

		it("should update BoolItem2 to true", function()
			local mockStatus = {
				BoolItem1 = false,
				BoolItem2 = false,
				ListItem1 = {
					"Hello",
				},
				ListItem2 = {},
			}
			local store = createTestStore({
				allPolicies = mockAllPolicies,
				policySettingStatus = mockStatus,
			})
			PlayerEmulatorService:SetEmulatedPolicyInfo(mockStatus)
			local mockPlugin = MockStudioPlugin.new()
			store:dispatch(UpdatePolicyBooleanItem("BoolItem2", true, mockPlugin))
			local state = store:getState().Policies
			expect(state.allPolicies).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			expect(state.policySettingStatus.BoolItem2).to.equal(true)
			expect(PlayerEmulatorService:GetEmulatedPolicyInfo().BoolItem2).to.equal(true)
			expect(mockPlugin:GetSetting(Constants.POLICY_SETTING_KEY).BoolItem2).to.equal(true)
		end)

		it("should not update BoolItem3 since key not exist", function()
			local mockStatus = {
				BoolItem1 = false,
				BoolItem2 = false,
				ListItem1 = {
					"Hello",
				},
				ListItem2 = {},
			}
			local store = createTestStore({
				allPolicies = mockAllPolicies,
				policySettingStatus = mockStatus,
			})
			PlayerEmulatorService:SetEmulatedPolicyInfo(mockStatus)
			local mockPlugin = MockStudioPlugin.new()
			store:dispatch(UpdatePolicyBooleanItem("BoolItem3", true, mockPlugin))
			local state = store:getState().Policies
			expect(state.allPolicies).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			assert(deepEqual(state.policySettingStatus, mockStatus))
			assert(deepEqual(PlayerEmulatorService:GetEmulatedPolicyInfo(), mockStatus))
		end)

		-- set it back
		PlayerEmulatorService:SetEmulatedPolicyInfo(orignalPolicyInfo)
	end)

	describe("UpdatePolicyListItem", function()
		-- save the orignal value
		local orignalPolicyInfo = PlayerEmulatorService:GetEmulatedPolicyInfo()

		it("should add World to ListItem1", function()
			local mockStatus = {
				BoolItem1 = false,
				BoolItem2 = false,
				ListItem1 = {
					"Hello",
				},
				ListItem2 = {},
			}
			local store = createTestStore({
				allPolicies = mockAllPolicies,
				policySettingStatus = mockStatus,
			})
			PlayerEmulatorService:SetEmulatedPolicyInfo(mockStatus)
			local mockPlugin = MockStudioPlugin.new()
			store:dispatch(UpdatePolicyListItem("ListItem1", "World", mockPlugin))
			local state = store:getState().Policies
			expect(state.allPolicies).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			assert(Cryo.List.find(state.policySettingStatus.ListItem1, "World") > 0)
			assert(Cryo.List.find(PlayerEmulatorService:GetEmulatedPolicyInfo().ListItem1, "World") > 0)
			assert(Cryo.List.find(mockPlugin:GetSetting(Constants.POLICY_SETTING_KEY).ListItem1, "World") > 0)
		end)

		it("should not update Aloha to ListItem1", function()
			local mockStatus = {
				BoolItem1 = false,
				BoolItem2 = false,
				ListItem1 = {
					"Hello",
				},
				ListItem2 = {},
			}
			local store = createTestStore({
				allPolicies = mockAllPolicies,
				policySettingStatus = mockStatus,
			})
			PlayerEmulatorService:SetEmulatedPolicyInfo(mockStatus)
			local mockPlugin = MockStudioPlugin.new()
			store:dispatch(UpdatePolicyListItem("ListItem1", "Aloha", mockPlugin))
			local state = store:getState().Policies
			expect(state.allPolicies).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			expect(Cryo.List.find(state.policySettingStatus.ListItem1, "Aloha")).to.equal(nil)
			expect(Cryo.List.find(PlayerEmulatorService:GetEmulatedPolicyInfo(), "Aloha")).to.equal(nil)
			expect(mockPlugin:GetSetting(Constants.POLICY_SETTING_KEY)).to.equal(nil)
		end)

		it("should remove Hello to ListItem1", function()
			local mockStatus = {
				BoolItem1 = false,
				BoolItem2 = false,
				ListItem1 = {
					"Hello",
				},
				ListItem2 = {},
			}
			local store = createTestStore({
				allPolicies = mockAllPolicies,
				policySettingStatus = mockStatus,
			})
			PlayerEmulatorService:SetEmulatedPolicyInfo(mockStatus)
			local mockPlugin = MockStudioPlugin.new()
			store:dispatch(UpdatePolicyListItem("ListItem1", "Hello", mockPlugin))
			local state = store:getState().Policies
			expect(state.allPolicies).to.be.ok()
			expect(state.policySettingStatus).to.be.ok()
			expect(type(state.allPolicies)).to.equal("table")
			expect(type(state.policySettingStatus)).to.equal("table")
			expect(Cryo.List.find(state.policySettingStatus.ListItem1, "Hello")).to.equal(nil)
			expect(Cryo.List.find(PlayerEmulatorService:GetEmulatedPolicyInfo().ListItem1, "Hello")).to.equal(nil)
			expect(Cryo.List.find(mockPlugin:GetSetting(Constants.POLICY_SETTING_KEY).ListItem1, "Hello")).to.equal(nil)
		end)

		-- set it back
		PlayerEmulatorService:SetEmulatedPolicyInfo(orignalPolicyInfo)
	end)
end