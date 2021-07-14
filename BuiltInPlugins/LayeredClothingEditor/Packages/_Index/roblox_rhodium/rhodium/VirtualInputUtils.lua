local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local runSet = {}
local signals = {}

RunService.Heartbeat:Connect(function(dt)
	local finishedList = {}
	for runable, _ in pairs(runSet) do
		local finished = runable(dt)
		if finished then
			table.insert(finishedList, runable)
		end
	end

	for _, toDelete in ipairs(finishedList) do
		runSet[toDelete] = nil
	end

	for signal, _ in pairs(signals) do
		if signal == false then
			signals[signal] = nil
		else
			signal:Fire(dt)
		end
	end
end)

local VirtualInputUtils = {}

local currentWindow = nil

function VirtualInputUtils.setCurrentWindow(window)
	local old = currentWindow
    currentWindow = window
	return old
end

function VirtualInputUtils.getCurrentWindow()
    return currentWindow
end

function VirtualInputUtils.__asyncRun(runable)
	runSet[runable] = true
end

function VirtualInputUtils.__syncRun(runable)
	local signal = Instance.new("BindableEvent")
	signals[signal] = true
	local dt = 0
	while true do
		local finished = runable(dt)
		if finished then break end
		dt = signal.Event:Wait()
	end
	signals[signal] = false
end

function VirtualInputUtils.__handleGuiInset(x, y)
	local guiOffset, _ = GuiService:GetGuiInset()
	return x + guiOffset.X, y + guiOffset.Y
end

return VirtualInputUtils