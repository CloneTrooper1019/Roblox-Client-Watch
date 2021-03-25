--[[
	An entry in an InfoPanel that renders a component's example,
	or nothing if the component does not have an example.

	Required Props:
		string Name: The name of the component to render an example for.

	Optional Props:
		number LayoutOrder: The sort order of this component.
]]

local SelectionService = game:GetService("Selection")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Render = require(Plugin.Packages.Framework).Examples.Render

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local Util = Framework.Util
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local UI = Framework.UI
local Pane = UI.Pane

local PanelEntry = require(Plugin.Src.Components.PanelEntry)
local StoryHost = require(Plugin.Src.Components.StoryHost)

local RenderExample = Roact.PureComponent:extend("RenderExample")

function RenderExample:init()
	self.containerRef = Roact.createRef()
	self.state = {
		story = nil,
	}
end

function RenderExample:loadExampleComponent()
	-- Fallback to None: if there is no Name prop provided, or if there is no result returned from Render
	self:setState({
		story = self.props.Name and Render(self.props.Name) or Roact.None
	})
end

function RenderExample:didMount()
	self:loadExampleComponent()

	-- Focus the example container Frame in the Explorer
	-- Not having this in a spawn can result in rare crashes of Studio
	spawn(function()
		if self.containerRef.current then
			SelectionService:Set({self.containerRef.current})
		end
	end)
end

function RenderExample:didUpdate(prevProps)
	if prevProps.Name ~= self.props.Name then
		self:loadExampleComponent()
	end
end

function RenderExample:render()
	local props = self.props
	local state = self.state

	local story = state.story

	local layoutOrder = props.LayoutOrder
	local sizes
	local style = props.Stylizer
	if THEME_REFACTOR then
		sizes = style.Sizes
	else
		sizes = props.Theme:get("Sizes")
	end
	if not story then
		return nil
	end

	return Roact.createElement(PanelEntry, {
		Header = "Example",
		LayoutOrder = layoutOrder,
	}, {
		Pane = Roact.createElement(Pane, {
			LayoutOrder = 2,
			Padding = sizes.OuterPadding,
			Layout = Enum.FillDirection.Vertical,
			AutomaticSize = Enum.AutomaticSize.Y,
			[Roact.Ref] = self.containerRef
		}, {
			Example = Roact.createElement(StoryHost, {
				Story = story,
			}),
		})
	})
end

ContextServices.mapToProps(RenderExample, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return RenderExample
