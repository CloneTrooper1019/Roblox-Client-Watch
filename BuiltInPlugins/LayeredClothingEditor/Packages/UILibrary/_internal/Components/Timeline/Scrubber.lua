-- TODO: Delete file when FFlagRemoveUILibraryTimeline is retired
--[[
	Generic implementation of a Scrubber for a Timeline

	Properties:
		UDim2 Position = position of the scrubber head
		UDim2 HeadSize = size of the scrubber head
		float Height = length of the scrubber line
		bool ShowHead = whether or not the scrubber head is visible
		Vector2 AnchorPoint = anchor point for the Scrubber component
		int ZIndex = display order of the scrubber component
		int thickness = pixel width of the scrubber line
]]

local Library = script.Parent.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)
local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local Scrubber = Roact.PureComponent:extend("Scrubber")

function Scrubber:render()
	return withTheme(function(theme)
		local props = self.props

		local position = props.Position
		local headSize = props.HeadSize
		local height = props.Height
		local showHead = props.ShowHead
		local anchorPoint = props.AnchorPoint
		local zIndex = props.ZIndex
		local thickness = props.Thickness

		local children = props[Roact.Children]
		if not children then
			children = {}
		end
		if showHead then
			table.insert(children, Roact.createElement("ImageLabel", {
				Image = theme.scrubber.image,
				ImageColor3 = theme.scrubber.backgroundColor,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
			}))
		end

		table.insert(children, Roact.createElement("Frame", {
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(0, thickness, 0, height),
			BackgroundColor3 = theme.scrubber.backgroundColor,
			AnchorPoint = Vector2.new(0.5, 0),
			BorderSizePixel = 0,
		}))

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Position = position,
			Size = headSize,
			ZIndex = zIndex,
			AnchorPoint = anchorPoint,
			[Roact.Event.InputBegan] = self.onDragBegan,
		}, children)
	end)
end

return Scrubber