--[[
	Final screen in the flow to let the user publish their cage edits.

	Required Props:
		callback GoToNext: request to go to next screen in flow.
		callback GoToPrevious: request to go to previous screen in flow.
		callback FinishEditing: callback for finalizing edits and publishing cages, provided via mapDispatchToProps
		callback ReleaseEditor: callback for restoring editor to default state, provided via mapDispatchToProps
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		table EditingItemContext: An EditingItemContext, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local ReleaseEditor = require(Plugin.Src.Thunks.ReleaseEditor)

local FlowScreenLayout = require(Plugin.Src.Components.Screens.FlowScreenLayout)
local FinishEditing = require(Plugin.Src.Thunks.FinishEditing)

local GenerateScreen = Roact.PureComponent:extend("GenerateScreen")

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(GenerateScreen, script)

function GenerateScreen:init()
	self.onGenerateClicked = function()
		local editingItem = self.props.EditingItemContext:getItem()
		local sourceItem = self.props.EditingItemContext:getSourceItem()
		self.props.FinishEditing(editingItem, sourceItem)

		-- return to start screen
		self.props.EditingItemContext:clear()
		self.props.GoToNext()
		self.props.ReleaseEditor()
	end
end

function GenerateScreen:render()
	local props = self.props

	local goToPrevious = props.GoToPrevious
	local localization = props.Localization
	local theme = props.Stylizer

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = theme.BackgroundColor,
		BorderSizePixel = 0,
	}, {
		Screen = Roact.createElement(FlowScreenLayout, {
			Title = localization:getText("Editor", "Generate"),
			PromptText = localization:getText("Generate", "Prompt"),
			NextButtonText = localization:getText("Flow", "Generate"),
			BackButtonText = localization:getText("Flow", "Back"),
			NextButtonEnabled = true,
			BackButtonEnabled = true,
			HasBackButton = true,
			GoToNext = self.onGenerateClicked,
			GoToPrevious = goToPrevious,
		})
	})
end

ContextServices.mapToProps(GenerateScreen,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
	EditingItemContext = EditingItemContext,
})

local function mapDispatchToProps(dispatch)
	return {
		FinishEditing = function(item, sourceItem)
			dispatch(FinishEditing(item, sourceItem))
		end,

		ReleaseEditor = function()
			dispatch(ReleaseEditor())
		end,
	}
end

return RoactRodux.connect(nil, mapDispatchToProps)(GenerateScreen)