--[[
	Generic wrapper component for detecting double click actions

	Props:
		number layoutOrder = sort order of frame in a layout
		callback onDoubleClickSuccess = function to call when double click is successful
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local DoubleClickDetector = Roact.PureComponent:extend("DoubleClickDetector")

local DOUBLE_CLICK_WAIT = 0.5

function DoubleClickDetector:init()
	self.clickStartTime = nil

	self.onClick = function()
		if not self.props.onDoubleClickSuccess then
			return
		end
		if self.clickStartTime == nil then
			self.clickStartTime = tick()
		else
			local timeSinceLastClick = tick() - self.clickStartTime
			if timeSinceLastClick <= DOUBLE_CLICK_WAIT then
				self.props.onDoubleClickSuccess()
			end
			self.clickStartTime = nil
		end
	end
end

function DoubleClickDetector:render()
	local props = self.props

	local layoutOrder = props.layoutOrder
	local children = props[Roact.Children]

	return Roact.createElement("TextButton", {
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Roact.Event.MouseButton1Click] = self.onClick,
	}, children)
end

return DoubleClickDetector