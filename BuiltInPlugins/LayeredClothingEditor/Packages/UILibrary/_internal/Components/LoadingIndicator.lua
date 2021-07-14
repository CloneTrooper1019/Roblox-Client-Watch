--[[
	Loading indicator

	Props:
		Vector2 AnchorPoint = Vector2.new(0, 0)
		UDim2 Position = UDim2.new(0, 0, 0, 0)
		UDim2 Size = UDim2.new(0, 92, 0, 24)
		number ZIndex = 0
		boolean Visible = true
		number Count = 3 : number of blocks in loading animation
		number GapRatio = 1.5 : sets gap between blocks
		number EndRatio = 0.25 : used for calculating block width
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local RunService = game:GetService("RunService")

local LoadingIndicator = Roact.PureComponent:extend("LoadingIndicator")

local ANIMATION_SPEED = 5
local DEFAULT_BLOCK_COUNT = 3

function LoadingIndicator:init()
	self.state = {
		animationTime = math.pi / 2,
		sinTime = 1,
		direction = 1,
		index = 1,
	}

	self.animationConnection = RunService.RenderStepped:connect(function(deltaTime)
		self:updateAnimation(deltaTime)
	end)
end

function LoadingIndicator:willUnmount()
	if self.animationConnection then
		self.animationConnection:Disconnect()
	end
end

function LoadingIndicator:updateAnimation(deltaTime)
	self:setState(function(prevState, props)
		local newAnimationTime = prevState.animationTime + deltaTime
		local newSinTime = math.sin(newAnimationTime * ANIMATION_SPEED)

		local direction = prevState.direction
		local newDirection = direction
		local newIndex = prevState.index

		-- If sin has changed sign, move to the next block
		if (direction > 0 and newSinTime < 0) or (direction < 0 and newSinTime > 0) then
			newDirection = -direction
			newIndex = newIndex + 1

			if newIndex > (self.props.count or DEFAULT_BLOCK_COUNT) then
				newIndex = 1
			end
		end

		return {
			animationTime = newAnimationTime,
			sinTime = newSinTime,
			direction = newDirection,
			index = newIndex,
		}
	end)
end

function LoadingIndicator:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state

		local loadingIndicatorTheme = theme.loadingIndicator

		local baseColor = loadingIndicatorTheme.baseColor
		local endColor = loadingIndicatorTheme.endColor

		local anchorPoint = props.AnchorPoint or Vector2.new(0, 0)
		local position = props.Position or UDim2.new(0, 0, 0, 0)
		local size = props.Size or UDim2.new(0, 92, 0, 24)
		local zindex = props.ZIndex or 0
		local visible = (props.Visible ~= nil and props.Visible) or (props.Visible == nil)

		local blockCount = props.Count or DEFAULT_BLOCK_COUNT

		local gapBetweenBlockRatio = props.GapRatio or 1.5
		local endRatio = props.EndRatio or 0.25

		local blockWidth = 1 / (blockCount + (blockCount * gapBetweenBlockRatio) - gapBetweenBlockRatio + (2 * endRatio))
		local gapWidth = blockWidth * gapBetweenBlockRatio

		local smallHeight = 0.6

		local children = {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(gapWidth, 0),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		}

		local sinTime = math.abs(state.sinTime)
		local index = state.index

		for i = 1, blockCount, 1 do
			local height = i == index and smallHeight + ((1 - smallHeight) * sinTime) or smallHeight

			local color = i == index and baseColor:lerp(endColor, sinTime) or baseColor

			children["Frame" .. i] = Roact.createElement("Frame", {
				Size = UDim2.new(blockWidth, 0, height, 0),
				LayoutOrder = i,
				BorderSizePixel = 0,
				BackgroundColor3 = color,
			})
		end

		return Roact.createElement("Frame", {
			AnchorPoint = anchorPoint,
			Position = position,
			Size = size,
			ZIndex = zindex,
			BorderSizePixel = 0,
			Visible = visible,
			BackgroundTransparency = 1,
		}, children)
	end)
end

return LoadingIndicator
