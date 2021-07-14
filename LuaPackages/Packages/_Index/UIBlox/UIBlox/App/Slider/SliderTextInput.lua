-- Specialized TextBox for handling the text boxes that sliders can have.

local UserInputService = game:GetService("UserInputService")

local Packages = script.Parent.Parent.Parent.Parent

local Roact = require(Packages.Roact)
local t = require(Packages.t)

local ImageSetComponent = require(Packages.UIBlox.Core.ImageSet.ImageSetComponent)
local Images = require(Packages.UIBlox.App.ImageSet.Images)
local withStyle = require(Packages.UIBlox.Core.Style.withStyle)

local divideTransparency = require(Packages.UIBlox.Utility.divideTransparency)

local ExternalEventConnection = require(Packages.UIBlox.Utility.ExternalEventConnection)

local SliderTextInput = Roact.PureComponent:extend("SliderTextInput")
SliderTextInput.validateProps = t.strictInterface({
	position = t.optional(t.union(t.UDim2, t.table)),
	anchorPoint = t.optional(t.Vector2),
	value = t.number,
	min = t.number,
	max = t.number,
	disabled = t.optional(t.boolean),
	stepInterval = t.numberPositive,
	onValueChanged = t.callback,
	layoutOrder = t.optional(t.integer),
})

SliderTextInput.defaultProps = {
	disabled = false,
}

function SliderTextInput:init()
	self.textBoxRef = Roact.createRef()
end

function SliderTextInput:render()
	return withStyle(function(style)
		local transparencyDivisor = self.props.disabled and 2 or 1
		local textTransparency = divideTransparency(
			style.Theme.TextDefault.Transparency,
			transparencyDivisor)

		local borderTransparency = divideTransparency(
			style.Theme.Divider.Transparency,
			transparencyDivisor)

		local backgroundTransparency = divideTransparency(
			style.Theme.BackgroundUIContrast.Transparency,
			transparencyDivisor)

		return Roact.createElement(ImageSetComponent.Label, {
			BackgroundTransparency = 1,
			Image = Images["component_assets/circle_16"],
			ImageColor3 = style.Theme.BackgroundUIContrast.Color,
			ImageTransparency = backgroundTransparency,
			Position = self.props.position,
			AnchorPoint = self.props.anchorPoint,
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromOffset(56, 36),
			SliceCenter = Rect.new(8, 8, 8, 8),
			LayoutOrder = self.props.layoutOrder,
		}, {
			Border = Roact.createElement(ImageSetComponent.Label, {
				BackgroundTransparency = 1,
				Image = Images["component_assets/circle_17_stroke_1"],
				ImageColor3 = style.Theme.Divider.Color,
				ImageTransparency = borderTransparency,
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 1),
				SliceCenter = Rect.new(8, 8, 8, 8),
			}),
			TextBox = Roact.createElement("TextBox", {
				[Roact.Ref] = self.textBoxRef,
				BackgroundTransparency = 1,
				ClearTextOnFocus = false,
				Font = style.Font.Body.Font,
				TextSize = style.Font.Body.RelativeSize * style.Font.BaseSize,
				TextColor3 = style.Theme.TextDefault.Color,
				TextTransparency = textTransparency,
				Size = UDim2.fromScale(1, 1),
				Text = tostring(self.props.value),
				TextScaled = true,
				TextEditable = not self.props.disabled,
				ZIndex = 2,

				[Roact.Event.Focused] = self.props.disabled and function(rbx)
					rbx:ReleaseFocus()
				end or nil,
				[Roact.Event.FocusLost] = function(rbx, enterPressed)
					if not enterPressed then
						return
					end

					local newValue = tonumber(rbx.Text)

					if newValue == nil then
						rbx.Text = tostring(self.props.value)
						return
					end

					newValue = math.clamp(
						math.floor(newValue / self.props.stepInterval + 0.5) * self.props.stepInterval,
						self.props.min,
						self.props.max)

					self.props.onValueChanged(newValue)
				end,
			}, {
				TextSizeConstraint = Roact.createElement("UITextSizeConstraint", {
					MinTextSize = style.Font.Body.RelativeMinSize * style.Font.BaseSize,
					MaxTextSize = style.Font.Body.RelativeSize * style.Font.BaseSize,
				})
			}),
			UserInputConnection = not self.props.disabled and Roact.createElement(ExternalEventConnection, {
				event = UserInputService.InputBegan,
				callback = function(input, gameProcessed)
					if input.UserInputType ~= Enum.UserInputType.Keyboard then
						return
					end

					if UserInputService:GetFocusedTextBox() ~= self.textBoxRef.current then
						return
					end

					local direction = 0
					if input.KeyCode == Enum.KeyCode.Up then
						direction = 1
					elseif input.KeyCode == Enum.KeyCode.Down then
						direction = -1
					end

					if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
						or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
						direction = direction * 10
					end

					if direction ~= 0 then
						local rawNewValue = self.props.value + self.props.stepInterval * direction
						local newValue = math.clamp(
							math.floor(rawNewValue / self.props.stepInterval + 0.5) * self.props.stepInterval,
							self.props.min,
							self.props.max)

						if newValue ~= self.props.value then
							self.props.onValueChanged(newValue)
						end
					end
				end,
			})
		})
	end)
end

function SliderTextInput:didMount()
	-- Set the textbox's TextInputType here, because the property is RobloxScript
	-- only and not accessible in Horsecat or some tests.
	pcall(function()
		self.textBoxRef.current.TextInputType = Enum.TextInputType.Number
	end)
end

return SliderTextInput
