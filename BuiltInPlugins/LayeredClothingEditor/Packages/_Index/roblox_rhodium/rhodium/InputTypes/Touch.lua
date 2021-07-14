local VirtualInputUtils = require(script.Parent.Parent.VirtualInputUtils)

local VirtualInputManager = game:GetService("VirtualInputManager")

local Touch = {}
local defaultTouchId = 123456

function Touch.SendTouchEvent(touchId, state, x, y)
	x, y = VirtualInputUtils.__handleGuiInset(x, y)
	VirtualInputManager:SendTouchEvent(touchId, state, x, y)
end

function Touch.touchStart(vec2, multitouchId)
	local touchId = defaultTouchId + (multitouchId or 0)
	Touch.SendTouchEvent(touchId, 0, vec2.x, vec2.y)
end

function Touch.touchMove(vec2, multitouchId)
	local touchId = defaultTouchId + (multitouchId or 0)
	Touch.SendTouchEvent(touchId, 1, vec2.x, vec2.y)
end

function Touch.touchStop(vec2, multitouchId)
	local touchId = defaultTouchId + (multitouchId or 0)
	Touch.SendTouchEvent(touchId, 2, vec2.x, vec2.y)
end

local function smoothSwipe(posFrom, posTo, duration, multitouchId)
	local passed = 0
	local started = false
	local touchId = defaultTouchId + (multitouchId or 0)
	return function(dt)
		if not started then
			Touch.touchStart(posFrom, touchId)
			started = true
		else
			passed = passed + dt
			if duration and passed < duration then
				local percent = passed / duration
				local pos = (posTo - posFrom) * percent + posFrom
				Touch.touchMove(pos, touchId)
			else
				Touch.touchMove(posTo, touchId)
				Touch.touchStop(posTo, touchId)
				return true
			end
		end
		return false
	end
end

function Touch.swipe(posFrom, posTo, duration, async, multitouchId)
	local touchId = defaultTouchId + (multitouchId or 0)
	if async == true then
		VirtualInputUtils.__asyncRun(smoothSwipe(posFrom, posTo, duration, touchId))
	else
		VirtualInputUtils.__syncRun(smoothSwipe(posFrom, posTo, duration, touchId))
	end
end

function Touch.touchScroll(startPos, xOffset, yOffset, duration, async, multitouchId)
	local posTo = startPos + Vector2.new(xOffset, yOffset)
	Touch.swipe(startPos, posTo, duration, async, multitouchId)
end

function Touch.tap(vec2)
	Touch.touchStart(vec2)
	Touch.touchStop(vec2)
end

return Touch