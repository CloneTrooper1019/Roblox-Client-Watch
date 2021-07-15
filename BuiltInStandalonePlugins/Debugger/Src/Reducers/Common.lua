local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Cryo = require(Plugin.Packages.Cryo)

local Actions = Plugin.Src.Actions
local SetCurrentThreadAction = require(Actions.Callstack.SetCurrentThread)
local SetCurrentFrameNumberAction = require(Actions.Callstack.SetCurrentFrameNumber)
local ResumedAction = require(Actions.Common.Resumed)

type ThreadId = number
type FrameNumber = number

type CommonStore = {
	currentThreadId : ThreadId,
	threadIdToCurrentFrameNumber : {[ThreadId] : FrameNumber}
}

return Rodux.createReducer({
	currentThreadId = -1,
	threadIdToCurrentFrameNumber = {}
}, {
	[SetCurrentThreadAction.name] = function(state : CommonStore, action : SetCurrentFrameNumberAction.Props)
		return Cryo.Dictionary.join(state, {
			currentThreadId = action.currentThreadId,
		})
	end,

	[SetCurrentFrameNumberAction.name] = function(state : CommonStore, action : SetCurrentFrameNumberAction.Props)
		return Cryo.Dictionary.join(state, {
			threadIdToCurrentFrameNumber = Cryo.Dictionary.join(state.threadIdToCurrentFrameNumber, {
				[action.threadId] = action.currentFrame,
			})
		})
	end,

	[ResumedAction.name] = function(state : CommonStore, action)
		return Cryo.Dictionary.join(state, {
			currentThreadId = -1,
			ThreadIDToCurrentFrameNumber = {}
		})
	end,
})
