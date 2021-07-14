--[[
	A line of text prefaced with a bullet point. Useful for lists of entries.

	Props:
        string Text = The text to display after the bullet point
        int LayoutOrder = Order in which the element is placed
        int TextSize = The size of text
        bool TextWrapped = Sets text wrapped
        bool TextTruncate = Sets text truncate
]]

local TextService = game:GetService("TextService")

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local BulletPoint = Roact.PureComponent:extend("BulletPoint")

local TEXT_SIZE = 20

function BulletPoint:init()
	self.frameRef = Roact.createRef()
	self.textConnection = nil

	self.updateFrameSize = function()
		local frame = self.frameRef.current
		local sizeX = frame.AbsoluteSize.x
		local textSize = TextService:GetTextSize(
			self.props.Text,
			self.props.TextSize or TEXT_SIZE,
			Enum.Font.SourceSans,
			Vector2.new(sizeX, math.huge)
		)
		frame.Size = UDim2.new(1, 0, 0, textSize.y)
	end
end

function BulletPoint:didMount()
	local frame = self.frameRef.current
	self.textConnection = frame:GetPropertyChangedSignal("AbsoluteSize"):connect(self.updateFrameSize)
	self.updateFrameSize()
end

function BulletPoint:willUnmount()
	self.textConnection:Disconnect()
	self.textConnection = nil
end

function BulletPoint:render()
    return withTheme(function(theme)

        local textSize = self.props.TextSize or TEXT_SIZE
        local text = self.props.Text or ""

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = self.props.LayoutOrder or 1,
			Size = UDim2.new(1, 0, 0, 0),

			[Roact.Ref] = self.frameRef,
		}, {
			Text = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 16, 0, -1),
				Size = UDim2.new(1, -16, 1, 0),
				Text = text,
				Font = theme.bulletPoint.font,
				TextColor3 = theme.bulletPoint.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = self.props.TextWrapped or nil,
				TextSize = textSize,
				TextTruncate = self.props.TextTruncate or nil,
			}),

			Dot = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 4, 0, 4),
				AnchorPoint = Vector2.new(0, 0.5),
				TextColor3 = theme.bulletPoint.text,
				Text = "•",
				TextYAlignment = Enum.TextYAlignment.Top,
				Font = theme.bulletPoint.font,
				TextSize = textSize,
			}),
		})
	end)
end

return BulletPoint
