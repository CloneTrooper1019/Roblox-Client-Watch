local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)

local Reducers = Plugin.Src.Reducers
local CallstackReducer = require(Reducers.Callstack)
local MainMiddleware = require(Plugin.Src.Middleware.MainMiddleware)

local Mocks = Plugin.Src.Mocks
local mockPausedState = require(Mocks.PausedState)
local mockThreadState = require(Mocks.ThreadState)
local mockStackFrame = require(Mocks.StackFrame)
local mockScriptRef = require(Mocks.ScriptRef)

local Actions = Plugin.Src.Actions
local BreakpointHitAction = require(Actions.Common.BreakpointHit)

local RequestThreadsThunk = require(script.Parent.RequestThreadsThunk)

local Models = Plugin.Src.Models
local DebuggerStateToken = require(Models.DebuggerStateToken)
local defaultDebuggerToken = DebuggerStateToken.fromData({session = 1, stepNumber = 1})

return function()
	it("should return its expected default state", function()
		local CallstackReducer = Rodux.Store.new(CallstackReducer)
		expect(CallstackReducer:getState()).to.be.ok()

	end)

	it("should accurately reflect the updates", function()
		local store = Rodux.Store.new(CallstackReducer, nil, MainMiddleware)
		
		local testStackFrameOne = mockStackFrame.new(10, mockScriptRef.new(), "TestFrame1", "C")
		local testStackFrameTwo = mockStackFrame.new(20, mockScriptRef.new(), "TestFrame2", "C")
		local testCallstack = {
			testStackFrameOne,
			testStackFrameTwo,
		}
		local testThreadOne = mockThreadState.new(1, "TestThread1", true, testCallstack)
		local testThreadTwo = mockThreadState.new(2, "TestThread2", true, testCallstack)
		local threadMap = {
			[1] = testThreadOne,
			[2] = testThreadTwo,
		}
		local testPausedState = mockPausedState.new(Enum.DebuggerPauseReason.Requested, true, threadMap)
		
		store:dispatch(BreakpointHitAction(defaultDebuggerToken))
		store:dispatch(RequestThreadsThunk(testPausedState, nil, defaultDebuggerToken))
		
		local state = store:getState()
		expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList).to.equal(2)
		expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList[1].displayString).to.equal(testThreadOne:getThreadName())
		expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList[2].displayString).to.equal(testThreadTwo:getThreadName())
		expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList[1].threadId).to.equal(testThreadOne:getThreadId())
		expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList[2].threadId).to.equal(testThreadTwo:getThreadId())
	end)
	
	it("should accept paused state updates and reject thread state updates for valid pause state and invalid thread state", function()
		local store = Rodux.Store.new(CallstackReducer, nil, MainMiddleware)
		
		local testStackFrameOne = mockStackFrame.new(10, mockScriptRef.new(), "TestFrame1", "C")
		local testStackFrameTwo = mockStackFrame.new(20, mockScriptRef.new(), "TestFrame2", "C")
		local testCallstack = {
			testStackFrameOne,
			testStackFrameTwo,
		}
		local testThreadOne = mockThreadState.new(1, "TestThread1", false, testCallstack)
		local testThreadTwo = mockThreadState.new(2, "TestThread2", false, testCallstack)
		local threadMap = {
			[1] = testThreadOne,
			[2] = testThreadTwo,
		}
		local testPausedState = mockPausedState.new(Enum.DebuggerPauseReason.Requested, true, threadMap)
		
		store:dispatch(BreakpointHitAction(defaultDebuggerToken))
		store:dispatch(RequestThreadsThunk(testPausedState, nil, defaultDebuggerToken))

		local state = store:getState()
		expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList).to.equal(0)
		expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList[1].displayString).to.equal(testThreadOne:getThreadName())
		expect(state.stateTokenToCallstackVars[defaultDebuggerToken].threadList[2].displayString).to.equal(testThreadTwo:getThreadName())
	end)
	
	
	it("should reject all updates for invalid pause state and thread states", function()
		local store = Rodux.Store.new(CallstackReducer, nil, MainMiddleware)
		
		local testStackFrameOne = mockStackFrame.new(10, mockScriptRef.new(), "TestFrame1", "C")
		local testStackFrameTwo = mockStackFrame.new(20, mockScriptRef.new(), "TestFrame2", "C")
		local testCallstack = {
			testStackFrameOne,
			testStackFrameTwo,
		}
		local testThreadOne = mockThreadState.new(1, "TestThread1", false, testCallstack)
		local testThreadTwo = mockThreadState.new(2, "TestThread2", false, testCallstack)
		local threadMap = {
			[1] = testThreadOne,
			[2] = testThreadTwo,
		}
		local testPausedState = mockPausedState.new(Enum.DebuggerPauseReason.Requested, false, threadMap)
		
		store:dispatch(BreakpointHitAction(defaultDebuggerToken))
		store:dispatch(RequestThreadsThunk(testPausedState, nil, defaultDebuggerToken))

		local state = store:getState()
		expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList).to.equal(0)
		expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadList).to.equal(0)
	end)
	
	it("should reject all updates for invalid pause state and valid thread states", function()
		local store = Rodux.Store.new(CallstackReducer, nil, MainMiddleware)

		local testStackFrameOne = mockStackFrame.new(10, mockScriptRef.new(), "TestFrame1", "C")
		local testStackFrameTwo = mockStackFrame.new(20, mockScriptRef.new(), "TestFrame2", "C")
		local testCallstack = {
			testStackFrameOne,
			testStackFrameTwo,
		}
		local testThreadOne = mockThreadState.new(1, "TestThread1", true, testCallstack)
		local testThreadTwo = mockThreadState.new(2, "TestThread2", true, testCallstack)
		local threadMap = {
			[1] = testThreadOne,
			[2] = testThreadTwo,
		}
		local testPausedState = mockPausedState.new(Enum.DebuggerPauseReason.Requested, false, threadMap)

		store:dispatch(BreakpointHitAction(defaultDebuggerToken))
		store:dispatch(RequestThreadsThunk(testPausedState, nil, defaultDebuggerToken))

		local state = store:getState()
		expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadIdToFrameList).to.equal(0)
		expect(#state.stateTokenToCallstackVars[defaultDebuggerToken].threadList).to.equal(0)
	end)
end
