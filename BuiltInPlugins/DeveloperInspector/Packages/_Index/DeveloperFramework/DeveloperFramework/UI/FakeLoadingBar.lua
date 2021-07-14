--[[
	A LoadingBar which plays a fake loading animation and holds at a specified value,
	then jumps to appear as completed when the Completed prop becomes true.
	If no HoldValue or Completed props are provided, it will simply play an animation
	of fully loading to completed over the course of LoadingTime.
	This component uses LoadingBar's StyleTables.
	See LoadingBar for more info.

	Required Props:
		number LoadingTime: The time in seconds that it takes for the LoadingBar to
			reach the end, or the HoldValue if one is specified.

	Optional Props:
		Style Style: The style with which to render this component.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		UDim2 Size: The size of this component.
		UDim2 Position: The position of this component.
		Vector2 AnchorPoint: The pivot point of this component's Position prop.
		number ZIndex: The render index of this component.
		number LayoutOrder: The layout order of this component in a list.
		boolean Completed: Whether the task that is being loaded has completed.
		number HoldValue: A number between 0 and 1 that the LoadingBar will
			hold at until Completed is true.
		callback OnProgressChanged: A callback for when the progress
			updates on the fake loading bar. Useful for progress text.
]]

local RunService = game:GetService("RunService")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local LoadingBar = require(Framework.UI.LoadingBar)
local Typecheck = require(Framework.Util).Typecheck

local FakeLoadingBar = Roact.PureComponent:extend("FakeLoadingBar")
Typecheck.wrap(FakeLoadingBar, script)

function FakeLoadingBar:init(initialProps)
	self.startTime = tick()
	self.lastProgress = 0
	self.state = {
		progress = 0,
	}

	self.updateProgress = function(progress)
		self:setState({
			progress = progress,
		})
		local props = self.props
		if progress ~= self.lastProgress then
			self.lastProgress = progress
			if props.OnProgressChanged then
				props.OnProgressChanged(progress)
			end
		end
	end

	local loadingTime = initialProps.LoadingTime
	assert(type(loadingTime) == "number", "FakeLoadingBar expects a 'LoadingTime' prop.")
	assert(loadingTime > 0, "FakeLoadingBar expects 'LoadingTime' to be > 0.")
	local holdValue = initialProps.HoldValue or 1
	assert(holdValue > 0, "FakeLoadingBar expects 'HoldValue' to be > 0.")
	assert(holdValue <= 1, "FakeLoadingBar expects 'HoldValue' to be <= 1.")

	self.updateConnection = RunService.RenderStepped:Connect(function()
		local props = self.props
		local currentTime = tick() - self.startTime
		local currentProgress
		if currentTime > loadingTime then
			if props.Completed then
				currentProgress = 1
			else
				currentProgress = holdValue
			end
		else
			currentProgress = (currentTime / loadingTime) * holdValue
		end
		self.updateProgress(currentProgress)
	end)
end

function FakeLoadingBar:willUnmount()
	if self.updateConnection then
		self.updateConnection:Disconnect()
	end
end

function FakeLoadingBar:render()
	local props = self.props
	local state = self.state

	local progress = math.clamp(state.progress, 0, 1)
	local style = props.Style
	local size = props.Size
	local position = props.Position
	local anchorPoint = props.AnchorPoint
	local zIndex = props.ZIndex
	local layoutOrder = props.LayoutOrder

	return Roact.createElement(LoadingBar, {
		Progress = progress,
		Style = style,
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		LayoutOrder = layoutOrder,
	})
end

return FakeLoadingBar
