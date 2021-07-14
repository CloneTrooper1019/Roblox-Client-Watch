--[[
	transparency slider wrapping around SliderSetting.
	When change the value, also change the transparency of the item

	Required Props:
		string Title: label text to the left of the slider
		number Value: slider value
		UDim2 Size: size of the component
		boolean IsDisabled: whether this component is disabled

	Optional Props:
		number LayoutOrder: sort order of frame in a layout
		Instance Item: item whose transparency will be change by the slider
		callback SetValue: function to call when set value
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)


local Constants = require(Plugin.Src.Util.Constants)
local SetTransparency = require(Plugin.Src.Util.SetTransparency)

local SliderSetting = require(Plugin.Src.Components.SliderSetting)

local TransparencySlider = Roact.PureComponent:extend("TransparencySlider")

local Framework = require(Plugin.Packages.Framework)
local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(TransparencySlider, script)

function TransparencySlider:init(initialProps)
	self.state = {
		value = initialProps.Value,
	}
	self.item = initialProps.Item
end

function TransparencySlider:didUpdate()
	local previousItem = self.item
	local currentItem = self.props.Item
	if previousItem ~= currentItem then
		self:setState({
			value = self.props.Value,
		})
	end
	self.item = currentItem
end

function TransparencySlider:render()
	local props = self.props

	local title = props.Title
	local item = props.Item
	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local isDisabled = props.IsDisabled
	local setValue = props.SetValue
	return Roact.createElement(SliderSetting, {
		Title = title,
		Value = self.state.value,
		MaxValue = Constants.MAX_TRANSPARENCY,
		Size = size,
		UsePercentage = true,
		LayoutOrder = layoutOrder,
		IsDisabled = isDisabled,
		SetValue = function(value)
			if setValue then
				setValue(value)
			end
			if item then
				SetTransparency(item, value)
			end
			self:setState({
				value = value,
			})
		end,
	})
end

return TransparencySlider