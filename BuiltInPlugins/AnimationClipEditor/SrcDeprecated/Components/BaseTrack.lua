--[[
	Represents a single track on the Dope Sheet meant to display a track's
	keyframes within a specified time range. This base track is a container
	for displaying keyframes, and tracks that use this component are responsible
	for adding keys.

	Properties:
		UDim2 Size = size of the container frame
		float Width = width of the keyframe display area frame
		bool Primary = Whether this track is a primary track (colored differently)
		bool ShowBackground = if this track should have an opaque background.
		int LayoutOrder = The layout order of the frame, if in a Layout.
		int ZIndex = The draw index of the frame.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)

local Theme = require(Plugin.SrcDeprecated.Context.Theme)
local withTheme = Theme.withTheme

local BaseTrack = Roact.PureComponent:extend("BaseTrack")

function BaseTrack:render()
	return withTheme(function(theme)
		local props = self.props

		local trackTheme = theme.trackTheme
		local size = props.Size
		local width = props.Width
		local layoutOrder = props.LayoutOrder
		local zIndex = props.ZIndex
		local primary = props.Primary
		local showBackground = props.ShowBackground

		local backgroundColor
		if primary then
			backgroundColor = trackTheme.primaryBackgroundColor
		elseif showBackground then
			backgroundColor = trackTheme.titleBackgroundColor
		end

		return Roact.createElement("Frame", {
			Size = size,
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundColor and 0 or 1,
			BorderSizePixel = 0,
			ZIndex = zIndex,
			LayoutOrder = layoutOrder,
		}, {
			KeyframeDisplayArea = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0, width, 1, 0),
				ZIndex = zIndex,
			}, self.props[Roact.Children])
		})
	end)
end

return BaseTrack