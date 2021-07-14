--[[
	Hoverable and clickable radio button, from a RadioButtonSet.

	Props:
		string Id = Unique identifier of this RadioButton
		string Title = Text to display on this RadioButton
		string Description = Smaller tooltip text to display below this RadioButton
		bool Selected = Whether to display this RadioButton as selected
		int Index = The order in which this RadioButton is displayed, top to bottom
		bool Enabled = Whether this RadioButton accepts input
	Optional Props:
		table{RoactComponents} Children, a table of Roact components that will be shown with this radio button.
			e.g. think of more things under the radio button like description.
]]
local TextService = game:GetService("TextService")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local Framework = Plugin.Framework
local FitFrameOnAxis = require(Framework.Util).FitFrame.FitFrameOnAxis
local ContextServices = require(Framework.ContextServices)

local RadioButton = Roact.PureComponent:extend("RadioButton")

function RadioButton:init(initialProps)
	self.mouseEnter = function()
		if self.props.Enabled then
			self:mouseHoverChanged(true)
		end
	end

	self.mouseLeave = function()
		if self.props.Enabled then
			self:mouseHoverChanged(false)
		end
	end

	local title = initialProps.Title
	local description = initialProps.Description or ""
end

function RadioButton:mouseHoverChanged(hovering)
	local props = self.props

	-- TODO: change to use HoverArea from Developer Framework
	if hovering then
		props.Mouse:__pushCursor("PointingHand")
	else
		props.Mouse:__resetCursor()
	end
end

function RadioButton:render()
	local props = self.props
	local theme = props.Theme:get("Plugin")

	local title = self.props.Title
	local description = props.Description and props.Description or nil
	local titleTextSize = TextService:GetTextSize(title, theme.fontStyle.Subtext.TextSize, theme.fontStyle.Subtext.Font, Vector2.new())

	local descriptionTextSize = props.Description and TextService:GetTextSize(description, theme.fontStyle.Subtext.TextSize, theme.fontStyle.Subtext.Font,
		Vector2.new(theme.radioButton.descriptionWidth, math.huge))

	local children = props.Children and props.Children or {}

	local minimumContentSize = math.max(titleTextSize.X, descriptionTextSize and descriptionTextSize.X or 0)
	local minimumButtonSize = minimumContentSize + theme.radioButton.size

	return Roact.createElement(FitFrameOnAxis, {
		axis = FitFrameOnAxis.Axis.Vertical,
		minimumSize = UDim2.new(0, minimumButtonSize, 0, 0),
		BackgroundTransparency = 1,
		FillDirection = Enum.FillDirection.Horizontal,

		LayoutOrder = props.LayoutOrder or 1,
	}, {
		Button = Roact.createElement("ImageButton", {
			Size = UDim2.new(0, theme.radioButton.size, 0, theme.radioButton.size),
			BackgroundTransparency = 1,
			ImageTransparency = self.props.Enabled and 0 or 0.4,
			Image = theme.radioButton.image.background,
			ImageColor3 = theme.radioButton.background,
			LayoutOrder = 1,

			[Roact.Event.MouseEnter] = self.mouseEnter,
			[Roact.Event.MouseLeave] = self.mouseLeave,

			-- Tell the RadioButtonSet that this is the currently selected button
			[Roact.Event.Activated] = function()
				if self.props.Enabled then
					self.props.OnClicked()
				end
			end,
		}, {
			Highlight = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = theme.isDarkerTheme and UDim2.new(0.4, 0, 0.4, 0) or UDim2.new(0.5, 0, 0.5, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Visible = self.props.Selected,
				Image = (self.props.Enabled and theme.radioButton.image.selected or theme.radioButton.image.selectedDisabled),
			}),
		}),

		ContentAndChildren = Roact.createElement(FitFrameOnAxis,{
			axis = FitFrameOnAxis.Axis.Vertical,
			minimumSize = UDim2.new(0, minimumContentSize, 0, 0),
			contentPadding = UDim.new(0, theme.radioButton.padding),
			BackgroundTransparency = 1,
			FillDirection = Enum.FillDirection.Vertical,

			LayoutOrder = 2,
		}, Cryo.Dictionary.join({
			TitleLabel = Roact.createElement("TextButton", Cryo.Dictionary.join(theme.fontStyle.Normal, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, titleTextSize.X, 0, titleTextSize.Y),

				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextTransparency = self.props.Enabled and 0 or 0.5,
				Text = title,

				[Roact.Event.MouseEnter] = self.mouseEnter,
				[Roact.Event.MouseLeave] = self.mouseLeave,

				[Roact.Event.Activated] = function()
					if self.props.Enabled then
						self.props.OnClicked()
					end
				end,

				LayoutOrder = -2,
			})),

			DescriptionLabel = props.Description and Roact.createElement("TextButton", Cryo.Dictionary.join(theme.fontStyle.Subtext,{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, descriptionTextSize.X, 0, descriptionTextSize.Y),

				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Text = description,
				TextWrapped = true,
				[Roact.Event.MouseEnter] = self.mouseEnter,
				[Roact.Event.MouseLeave] = self.mouseLeave,

				[Roact.Event.Activated] = function()
					if self.props.Enabled then
						self.props.OnClicked()
					end
				end,

				LayoutOrder = -1,
			})),
		}, children)),
	})
end

ContextServices.mapToProps(RadioButton, {
	Theme = ContextServices.Theme,
	Mouse = ContextServices.Mouse,
})

return RadioButton