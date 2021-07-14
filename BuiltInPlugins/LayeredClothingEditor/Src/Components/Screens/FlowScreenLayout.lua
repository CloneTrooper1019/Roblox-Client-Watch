--[[
	Generic component representing the layout for a typical screen in the flow.

	Required Props:
		string Title: text displayed in header area of screen.
		string PromptText: text displayed underneath header.
		string NextButtonText: text displayed on Next Button.
		string BackButtonText: text displayed on Back Button.
		boolean NextButtonEnabled: if the next button is interactable or not
		boolean HasBackButton: if the back button should be rendered.
		callback GoToNext: function fired when next button is clicked.
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		callback RenderContent: function renders optional elements to be displayed in the middle of the layout.
		number LayoutOrder: render order of component in layout.
		callback GoToPrevious: function fired when back button is clicked.
		boolean BackButtonEnabled: if the back button is interactable or not.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local UI = Framework.UI
local Button = UI.Button
local TextLabel = UI.Decoration.TextLabel

local Util = Framework.Util
local StyleModifier = Util.StyleModifier
local LayoutOrderIterator = Util.LayoutOrderIterator

local FlowScreenLayout = Roact.PureComponent:extend("FlowScreenLayout")

local SwizzleView = require(Plugin.Src.Components.SwizzleView)

local Typecheck = Util.Typecheck
Typecheck.wrap(FlowScreenLayout, script)

function FlowScreenLayout:init()
	self.emptyFunc = function()
		return nil
	end
end

function FlowScreenLayout:render()
	local props = self.props

	local title = props.Title
	local promptText = props.PromptText
	local backButtonText = props.BackButtonText
	local backButtonEnabled = props.BackButtonEnabled or false
	local nextButtonEnabled = props.NextButtonEnabled
	local nextButtonText = props.NextButtonText
	local hasBackButton = props.HasBackButton
	local layoutOrder = props.LayoutOrder or 1

	local goToNext = props.GoToNext
	local goToPrevious = props.GoToPrevious or self.emptyFunc
	local renderContent = props.RenderContent or self.emptyFunc

	local theme = props.Stylizer
	local orderIterator = LayoutOrderIterator.new()

	return Roact.createElement(SwizzleView, {
		Title = title,
		LayoutOrder = layoutOrder,
		StayOpen = true,
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, theme.MainPadding),
			PaddingLeft = UDim.new(0, theme.MainPadding),
			PaddingRight = UDim.new(0, theme.MainPadding),
		}),

		Prompt = Roact.createElement(TextLabel, {
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = promptText,
			TextWrapped = true,
			LayoutOrder = orderIterator:getNextOrder(),
		}),

		Content = renderContent(orderIterator:getNextOrder()),

		NextAndBackButtonContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, theme.ButtonHeight),
			LayoutOrder = orderIterator:getNextOrder(),
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, theme.MainPadding),
			}),

			BackButton = hasBackButton and Roact.createElement(Button, {
				Text = backButtonText,
				Style = "Round",
				StyleModifier = not backButtonEnabled and StyleModifier.Disabled or nil,
				Size = UDim2.new(0, theme.ButtonWidth, 0, theme.ButtonHeight),
				OnClick = goToPrevious or function() end,
				LayoutOrder = orderIterator:getNextOrder(),
			}),

			NextButton = Roact.createElement(Button, {
				Text = nextButtonText,
				Style = "Round",
				StyleModifier = not nextButtonEnabled and StyleModifier.Disabled or nil,
				Size = UDim2.new(0, theme.ButtonWidth, 0, theme.ButtonHeight),
				OnClick = goToNext or function() end,
				LayoutOrder = orderIterator:getNextOrder(),
			}),
		})
	})
end

ContextServices.mapToProps(FlowScreenLayout,{
	Stylizer = ContextServices.Stylizer,
})

return FlowScreenLayout