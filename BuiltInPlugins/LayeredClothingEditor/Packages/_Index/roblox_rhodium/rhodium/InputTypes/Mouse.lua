local VirtualInputUtils = require(script.Parent.Parent.VirtualInputUtils)

local VirtualInputManager = game:GetService("VirtualInputManager")
local InputVisualizer = require(script.Parent.Parent.InputVisualizer):new()

local Mouse = {}

function Mouse.sendMouseButtonEvent(x, y, button, isDown, repeatCount)
	x, y = VirtualInputUtils.__handleGuiInset(x, y)
	VirtualInputManager:SendMouseButtonEvent(x, y, button, isDown, VirtualInputUtils.getCurrentWindow(), repeatCount or 0)
end

function Mouse.SendMouseMoveEvent(x, y)
	x, y = VirtualInputUtils.__handleGuiInset(x, y)
	VirtualInputManager:SendMouseMoveEvent(x, y, VirtualInputUtils.getCurrentWindow())
end

function Mouse.SendMouseWheelEvent(x, y, isForwardScroll)
	x, y = VirtualInputUtils.__handleGuiInset(x, y)
	VirtualInputManager:SendMouseWheelEvent(x, y, isForwardScroll, VirtualInputUtils.getCurrentWindow())
end

function Mouse.mouseWheel(vec2, num)
	local forward = false
	if num < 0 then
		forward = true
		num = -num
	end
	for _ = 1, num do
		Mouse.SendMouseWheelEvent(vec2.x, vec2.y, forward)
	end
end

local function click(vec2, count, clickType)
	InputVisualizer:click(vec2, VirtualInputUtils.getCurrentWindow())
	Mouse.sendMouseButtonEvent(vec2.x, vec2.y, clickType, true, count)
	Mouse.sendMouseButtonEvent(vec2.x, vec2.y, clickType, false, count)
end

local function multiClick(vec2, count, clickType)
	local waiting = true
	local repeatCount = 0
	return function()
		if waiting then
			waiting = false
			return false
		elseif count >= 1 then
			click(vec2, repeatCount, clickType)
			count = count - 1
			repeatCount = repeatCount + 1
			waiting = true
			return false
		elseif count == 0 then
			return true
		end
	end
end

function Mouse.click(vec2)
	VirtualInputUtils.__syncRun(multiClick(vec2, 1, 0))
end

function Mouse.multiClick(vec2, count)
	VirtualInputUtils.__syncRun(multiClick(vec2, count, 0))
end

function Mouse.rightClick(vec2)
	VirtualInputUtils.__syncRun(multiClick(vec2, 1, 1))
end

function Mouse.mouseLeftDown(vec2)
	Mouse.sendMouseButtonEvent(vec2.x, vec2.y, 0, true)
end

function Mouse.mouseLeftUp(vec2)
	Mouse.sendMouseButtonEvent(vec2.x, vec2.y, 0, false)
end

function Mouse.mouseRightDown(vec2)
	Mouse.sendMouseButtonEvent(vec2.x, vec2.y, 1, true)
end

function Mouse.mouseRightUp(vec2)
	Mouse.sendMouseButtonEvent(vec2.x, vec2.y, 1, false)
end

function Mouse.mouseMove(vec2)
	Mouse.SendMouseMoveEvent(vec2.X, vec2.Y)
end

local function drag(posFrom, posTo, duration)
	local passed = 0
	local started = false
	return function(dt)
		if not started then
			Mouse.mouseLeftDown(posFrom)
			started = true
		else
			passed = passed + dt
			if duration and passed < duration then
				local percent = passed / duration
				local pos = (posTo - posFrom) * percent + posFrom
				Mouse.mouseMove(pos)
			else
				Mouse.mouseMove(posTo)
				Mouse.mouseLeftUp(posTo)
				return true
			end
		end
		return false
	end
end

function Mouse.mouseDrag(posFrom, posTo, duration)
	VirtualInputUtils.__syncRun(drag(posFrom, posTo, duration))
end

return Mouse