local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)

local Framework = require(Plugin.Packages.Framework)
local TestHelpers = Framework.TestHelpers
local testImmutability = TestHelpers.testImmutability

local CallstackReducer = require(script.Parent.Callstack)
local Actions = Plugin.Src.Actions
local Models = Plugin.Src.Models
local AddCallstackAction = require(Actions.Callstack.AddCallstack)
local AddThreadIdAction = require(Actions.Callstack.AddThreadId)
local ResumedAction = require(Actions.Common.Resumed)
local BreakpointHitAction = require(Actions.Common.BreakpointHit)
local DebuggerStateToken = require(Models.DebuggerStateToken)

local defaultDebuggerToken = DebuggerStateToken.fromData({session = 1, stepNumber = 1})

return function()
	it("should return its expected default state", function()
		local callstackReducer = Rodux.Store.new(CallstackReducer)
		expect(callstackReducer:getState()).to.be.ok()
		expect(callstackReducer:getState().stateTokenToCallstackVars).to.be.ok()
	end)

	describe(AddCallstackAction.name, function()
		it("should Add the Callstack", function()

			local testInfo = {
				arrowColumn = {
					value = "",
				},
				frameColumn = "a",
				whatColumn = "b",
				functionNameColumn = "c",
				lineNumberColumn = "d",
				sourceColumn = "e",
			}
			local prepState = CallstackReducer(nil, BreakpointHitAction(defaultDebuggerToken))
			local state = CallstackReducer(prepState, AddCallstackAction(123, testInfo, defaultDebuggerToken))
			expect(state).to.be.ok()
			expect(state.stateTokenToCallstackVars).to.be.ok()
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList).to.be.ok()
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList[123].frameColumn).to.equal("a")
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList[123].whatColumn).to.equal("b")
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList[123].functionNameColumn).to.equal("c")
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList[123].lineNumberColumn).to.equal("d")
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList[123].sourceColumn).to.equal("e")
		end)

		it("should preserve immutability", function()
			
			local testInfo2 = {
				arrowColumn = {
					value = "",
				},
				frameColumn = "aa",
				whatColumn = "b",
				functionNameColumn = "c",
				lineNumberColumn = "d",
				sourceColumn = "e",
			}
			local previousState = {stateTokenToCallstackVars = {
				[defaultDebuggerToken] = {
					threadList = {},
					threadIdToFrameList = {},
				}
			}}
			local immutabilityPreserved = testImmutability(CallstackReducer, AddCallstackAction(1234, testInfo2, defaultDebuggerToken), previousState)
			expect(immutabilityPreserved).to.equal(true)
		end)
	end)

	describe(AddThreadIdAction.name, function()
		it("should Add the ThreadId", function()
			local prepState = CallstackReducer(nil, BreakpointHitAction(defaultDebuggerToken))
			local state = CallstackReducer(prepState, AddThreadIdAction(123, "TestScript.Lua", defaultDebuggerToken))

			expect(state).to.be.ok()
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList).to.be.ok()
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList).to.be.ok()
			expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadList).to.equal(1)
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList[1].threadId).to.equal(123)
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList[1].displayString).to.equal("TestScript.Lua")
		end)

		local previousState = {stateTokenToCallstackVars = {
			[defaultDebuggerToken] = {
				threadList = {},
				threadIdToFrameList = {},
			}
		}}
		it("should preserve immutability", function()
			local immutabilityPreserved = testImmutability(CallstackReducer, AddThreadIdAction(1234, "TestScript2.Lua", defaultDebuggerToken), previousState)
			expect(immutabilityPreserved).to.equal(true)
		end)
	end)

	describe(ResumedAction.name, function()
		it("should clear to default state", function()
			local state = CallstackReducer(nil, ResumedAction())

			expect(state).to.be.ok()
			expect(state.stateTokenToCallstackVars).to.be.ok()
			expect(#state.stateTokenToCallstackVars).to.equal(0)
		end)

		it("should preserve immutability", function()
			local immutabilityPreserved = testImmutability(CallstackReducer, ResumedAction)
			expect(immutabilityPreserved).to.equal(true)
		end)
	end)

	describe(BreakpointHitAction.name, function()
		it("should should add empty data to state map", function()
			local state = CallstackReducer(nil, BreakpointHitAction(defaultDebuggerToken))
			expect(state).to.be.ok()
			expect(state.stateTokenToCallstackVars).to.be.ok()
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList).to.be.ok()
			expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadList).to.equal(0)
			expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList).to.be.ok()
			expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList).to.equal(0)
		end)

		it("should preserve immutability", function()
			local immutabilityPreserved = testImmutability(CallstackReducer, BreakpointHitAction)
			expect(immutabilityPreserved).to.equal(true)
		end)
	end)
end
