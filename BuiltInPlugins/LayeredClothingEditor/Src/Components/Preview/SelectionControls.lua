--[[
	Shows the Preview Panel transparency/animation controls

	Required Props:
		UDim2 Size: size of the frame
		number LayoutOrder: render order of component in layout
		string SelectedTab: the preview tab selection (this is an entry from PreviewConstants.TABS_KEYS)
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		table Localization: A Localization ContextItem, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local PreviewConstantsInterface = require(Plugin.Src.Util.PreviewConstantsInterface)

local SelectionControls = Roact.PureComponent:extend("SelectionControls")

local AnimPlaybackSlider = require(Plugin.Src.Components.AnimationPlayback.AnimPlaybackSlider)

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(SelectionControls, script)

function SelectionControls:render()
	local props = self.props
	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local theme = props.Stylizer

	local selectedTab = props.SelectedTab
	return Roact.createElement("Frame", {
		BackgroundColor3 = theme.BackgroundColor,
		Size = size,
		LayoutOrder = layoutOrder,

		BorderSizePixel = 0,
		BorderColor3 = theme.BorderColor,
	},{
		AnimPlaybackSlider = PreviewConstantsInterface.shouldTabShowPlaybackSlider(selectedTab) and Roact.createElement(AnimPlaybackSlider, {
			Size = UDim2.new(1, 0, 0, theme.SliderHeight),
		}),
	})
end

ContextServices.mapToProps(SelectionControls,{
	Stylizer = ContextServices.Stylizer,
})

local function mapStateToProps(state, props)
	local previewStatus = state.previewStatus

	return {
		SelectedTab = previewStatus.selectedTab,
	}
end

return RoactRodux.connect(mapStateToProps)(SelectionControls)