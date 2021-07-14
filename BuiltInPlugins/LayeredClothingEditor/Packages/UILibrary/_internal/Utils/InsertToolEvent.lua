local InsertToolEvent = {}
InsertToolEvent.__index = InsertToolEvent

InsertToolEvent.INSERT_TO_WORKSPACE = 0
InsertToolEvent.INSERT_TO_STARTER_PACK = 1
InsertToolEvent.INSERT_CANCELLED = 2

function InsertToolEvent.new(onPromptCallback)
	local self = {
		_onPromptCallback = onPromptCallback,
		_bindable = Instance.new("BindableEvent"),
		_waiting = false,
	}
	setmetatable(self, InsertToolEvent)
	return self
end

function InsertToolEvent:isWaiting()
	return self._waiting
end

function InsertToolEvent:destroy()
	self:cancel()
	self._bindable:Destroy()
end

function InsertToolEvent:insertToWorkspace()
	self._bindable:Fire(InsertToolEvent.INSERT_TO_WORKSPACE)
end

function InsertToolEvent:insertToStarterPack()
	self._bindable:Fire(InsertToolEvent.INSERT_TO_STARTER_PACK)
end

function InsertToolEvent:cancel()
	self._bindable:Fire(InsertToolEvent.INSERT_CANCELLED)
end

function InsertToolEvent:promptAndWait()
	if self._waiting then
		return InsertToolEvent.INSERT_CANCELLED
	end

	self._waiting = true
	self._onPromptCallback()
	local result = self._bindable.Event:Wait()
	self._waiting = false
	return result
end

return InsertToolEvent
