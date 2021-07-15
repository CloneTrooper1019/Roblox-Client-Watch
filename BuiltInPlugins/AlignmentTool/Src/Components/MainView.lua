--[[
	The top level view for the alignment plugin.

	Contains a UI section for each alignment setting, and button for aligning
	the selection using the current settings.
]]

local Plugin = script.Parent.Parent.Parent

local getFFlagAlignToolTeachingCallout = require(Plugin.Src.Flags.getFFlagAlignToolTeachingCallout)

local DraggerSchemaCore = Plugin.Packages.DraggerSchemaCore
local BoundsChangedTracker = require(DraggerSchemaCore.BoundsChangedTracker)
local Selection = require(DraggerSchemaCore.Selection)

local FitFrameVertical = require(Plugin.Packages.FitFrame).FitFrameVertical
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)

local ContextServices = Framework.ContextServices
local UI = Framework.UI
local Button = UI.Button
local Container = UI.Container
local Decoration = UI.Decoration
local ScrollingFrame = UI.ScrollingFrame

local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator
local StyleModifier = Util.StyleModifier

local SetAlignableObjects = require(Plugin.Src.Actions.SetAlignableObjects)
local AlignmentSettings = require(Plugin.Src.Components.AlignmentSettings)
local InfoLabel = require(Plugin.Src.Components.InfoLabel)
local AlignObjectsPreview = require(Plugin.Src.Components.AlignObjectsPreview)
local UpdateAlignEnabled = require(Plugin.Src.Thunks.UpdateAlignEnabled)
local UpdateAlignment = require(Plugin.Src.Thunks.UpdateAlignment)
local TeachingCallout = require(script.Parent.TeachingCallout)

local AlignToolError = require(Plugin.Src.Utility.AlignToolError)
local getAlignableObjects = require(Plugin.Src.Utility.getAlignableObjects)

local SelectionWrapper = Selection.new()

local MainView = Roact.PureComponent:extend("MainView")

function MainView:init()
	-- BoundsChangedTrackers take a context, but the Core schema does not use it
	-- so we can safely leave it nil here.
	local context = nil
	self._boundsChangedTracker = BoundsChangedTracker.new(context, function()
		self.props.updateAlignEnabled()
	end)

	self:_updateSelectionInfo()
end

function MainView:render()
	local props = self.props
	local state = self.state

	local enabled = props.alignEnabled
	local updateAlignment = props.updateAlignment
	local analytics = props.Analytics
	local localization = props.Localization
	local theme = props.Stylizer

	local layoutOrderIterator = LayoutOrderIterator.new()

	local errorText

	if not props.alignEnabled and props.disabledReason ~= nil then
		local errorCode = props.disabledReason.errorCode
		if errorCode then
			local formatParameters = props.disabledReason.formatParameters
			errorText = AlignToolError.getErrorText(localization, errorCode, formatParameters)
		end
	end

	-- Render the preview when it's a candidate for visibility thanks to the
	-- cursor being over the UI (previewVisible) and an alignment operation is
	-- currently possible (alignEnabled).
	local shouldRenderPreview = props.previewVisible and props.alignEnabled

	local padding = UDim.new(0, theme.MainView.Padding)

	return Roact.createElement(Container, {
		Background = Decoration.Box,
	}, {
		Scroller = Roact.createElement(ScrollingFrame, {
			AutoSizeCanvas = true,
			AutoSizeLayoutOptions = {
				Padding = theme.MainView.ListItemPadding,
			},
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = padding,
				PaddingTop = padding,
				-- PaddingRight omitted to prevent the layout from collapsing prematurely.
				PaddingBottom = padding,
			}),

			AlignmentSettings = Roact.createElement(AlignmentSettings, {
				LayoutOrder = layoutOrderIterator:getNextOrder(),
			}),

			InfoLabel = Roact.createElement(InfoLabel, {
				LayoutOrder = layoutOrderIterator:getNextOrder(),
				Text = errorText,
				Type = InfoLabel.Error,
			}),

			ButtonContainer = Roact.createElement(FitFrameVertical, {
				-- TODO: cleanup margin syntax (see https://github.com/Roblox/roact-fit-components/issues/11)
				margin = {
					left = 0,
					top = theme.MainView.Padding,
					right = 0,
					bottom = 0,
				},
				width = UDim.new(1, 0),
				BackgroundTransparency = 1,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				LayoutOrder = layoutOrderIterator:getNextOrder(),

			}, {
				Button = Roact.createElement(Button, {
					Size = theme.MainView.PrimaryButtonSize,
					Style = "RoundPrimary",
					StyleModifier = not enabled and StyleModifier.Disabled,
					Text = localization:getText("MainView", "AlignButton"),
					OnClick = function()
						if enabled then
							updateAlignment(analytics)
						end
					end,
				}, {
					TeachingCallout = getFFlagAlignToolTeachingCallout() and Roact.createElement(TeachingCallout, {
						Offset = Vector2.new(0, 6),
						DefinitionId = "AlignToolCallout",
						LocationId = "AlignButton",
					})
				}),
			}),
		}),

		AlignObjectsPreview = shouldRenderPreview and Roact.createElement(AlignObjectsPreview) or nil,
	})
end

function MainView:_updateSelectionInfo()
	local selection = SelectionWrapper:Get()
	local alignableObjects, allParts = getAlignableObjects(selection)

	self.props.setAlignableObjects(alignableObjects)

	self._boundsChangedTracker:setParts(allParts)
end

function MainView:didMount()
	self._boundsChangedTracker:install()

	self._selectionChangedConnection = SelectionWrapper.SelectionChanged:Connect(function()
		self:_updateSelectionInfo()
	end)
end

function MainView:willUnmount()
	self._selectionChangedConnection:Disconnect()
	self._selectionChangedConnection = nil

	self._boundsChangedTracker:uninstall()
end

ContextServices.mapToProps(MainView, {
	Localization = ContextServices.Localization,
	Plugin = ContextServices.Plugin,
	Stylizer = ContextServices.Stylizer,
	Analytics = ContextServices.Analytics,
})

local function mapStateToProps(state, _)
	return {
		previewVisible = state.previewVisible,
		alignEnabled = state.alignEnabled,
		disabledReason = state.disabledReason,
		alignableObjects = state.alignableObjects,
		alignmentMode = state.alignmentMode,
		alignmentSpace = state.alignmentSpace,
		enabledAxes = state.enabledAxes,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		updateAlignEnabled = function()
			dispatch(UpdateAlignEnabled())
		end,

		updateAlignment = function(analytics)
			dispatch(UpdateAlignment(analytics))
		end,

		setAlignableObjects = function(objects)
			dispatch(SetAlignableObjects(objects))
			dispatch(UpdateAlignEnabled())
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(MainView)
