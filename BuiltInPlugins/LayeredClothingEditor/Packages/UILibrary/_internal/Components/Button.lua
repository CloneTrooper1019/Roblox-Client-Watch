--!nolint UnknownGlobal
--^ DEVTOOLS-4930

--[[
	A button with rounded corners. Colors are based on Theme.

	Required Props:
		function RenderContents(theme, hovered) = A function that returns the
			contents that will display in the button. The parameters passed
			allow the function to style the contents based on the button's current
			theme and/or produce different contents if the button is hovered.

	Props:
		string Style = The theme to use for this button. Ex. "Default", "Primary".
			Styles for buttons can be found in createTheme.lua.
		string StyleState = Normally controlled by the button (e.g. hovered), but can
			be overwritten with something like 'disabled' to pull from override themes

		UDim2 Size = The size of the button.
		UDim2 Position = The position of the button.
		Vector2 AnchorPoint = The center point of the button.
		int LayoutOrder = The order in which this button appears in a UILayout.
		int ZIndex = The display index of this button.
		int BorderSizePixel = Border size of the button
]]

local Library = script.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme
local join = require(Library.join)

local RoundFrame = require(Library.Components.RoundFrame)

local Button = Roact.PureComponent:extend("Button")

local FFlagUILibraryButtonRenderPressed = game:DefineFastFlag("UILibraryButtonRenderPressed", false)

function Button:init(initialProps)
	self.state = {
		hovered = false,
		pressed = false
	}

	self.onClick = function()
		if self.props.OnClick then
			self.props.OnClick()
		end
	end

	self.mouseEnter = function()
		self:setState({
			hovered = true,
		})
	end

	self.mouseLeave = function()
		self:setState({
			hovered = false,
			pressed = false
		})
	end
	
	self.onMouseDown = function()
		self:setState({
			hovered = true,
			pressed = true,
		})
	end

	self.onMouseUp = function()
		self:setState({
			pressed = false,
		})
	end
end

function Button:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state
		local pressed = FFlagUILibraryButtonRenderPressed and state.pressed or nil
		local hovered = state.hovered
		local style = props.Style
		local styleState = props.StyleState
		local size = props.Size
		local position = props.Position
		local anchorPoint = props.AnchorPoint
		local layoutOrder = props.LayoutOrder
		local renderContents = props.RenderContents
		local zIndex = props.ZIndex
		local borderSize = props.BorderSizePixel

		assert(renderContents ~= nil and type(renderContents) == "function",
			"Button requires a RenderContents function.")

		local buttonTheme = style and theme.button[style] or theme.button.Default
		if styleState then
			buttonTheme = join(buttonTheme, buttonTheme[styleState])
		elseif pressed then
			buttonTheme = join(buttonTheme, buttonTheme.pressed)
		elseif hovered then
			buttonTheme = join(buttonTheme, buttonTheme.hovered)
		end

		local isRound = buttonTheme.isRound
		local content = renderContents(buttonTheme, hovered, pressed)

		local buttonProps = {
			Size = size,
			Position = position,
			AnchorPoint = anchorPoint,
			LayoutOrder = layoutOrder,
			ZIndex = zIndex,

			BackgroundColor3 = buttonTheme.backgroundColor,
			BorderColor3 = buttonTheme.borderColor,
			BorderSizePixel = borderSize,
		}

		if isRound then
			return Roact.createElement(RoundFrame, join(buttonProps, {
				OnActivated = self.onClick,
				OnMouseEnter = self.mouseEnter,
				OnMouseLeave = self.mouseLeave,
				[Roact.Event.MouseButton1Down] = self.onMouseDown,
				[Roact.Event.MouseButton1Up] = self.onMouseUp,
			}), content)
		else
			return Roact.createElement("ImageButton", join(buttonProps, {
				AutoButtonColor = false,

				[Roact.Event.MouseEnter] = self.mouseEnter,
				[Roact.Event.MouseLeave] = self.mouseLeave,
				[Roact.Event.Activated] = self.onClick,
				[Roact.Event.MouseButton1Down] = self.onMouseDown,
				[Roact.Event.MouseButton1Up] = self.onMouseUp,
			}), content)
		end
	end)
end

return Button
