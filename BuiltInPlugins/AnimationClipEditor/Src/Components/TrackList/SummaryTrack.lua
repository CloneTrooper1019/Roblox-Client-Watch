--[[
	Represents the top entry in a TrackList.

	Props:
		int LayoutOrder = The order this element displays in a UIListLayout.
		string Name = The name to display in this track.
		list<string> UnusedTracks = Tracks that are available to add but have not
			been added.

		function OnTrackAdded(track) = A callback for when the user clicks the
			add button and then selects a track to add to the TrackList.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local IKController = require(Plugin.Src.Components.IK.IKController)

local TrackListEntry = require(Plugin.Src.Components.TrackList.TrackListEntry)
local AddTrackButton = require(Plugin.Src.Components.TrackList.AddTrackButton)
local Constants = require(Plugin.Src.Util.Constants)
local isEmpty = require(Plugin.Src.Util.isEmpty)
local StringUtils = require(Plugin.Src.Util.StringUtils)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local SummaryTrack = Roact.PureComponent:extend("SummaryTrack")

local PADDING = 12

function SummaryTrack:init()
	self.onTrackAdded = function(instance, track, trackType)
		if self.props.OnTrackAdded then
			self.props.OnTrackAdded(instance, track, trackType)
		end
	end
end

function SummaryTrack:render()
		local props = self.props
		local theme = props.Theme:get("PluginTheme")
		local name = props.Name
		local layoutOrder = props.LayoutOrder
		local tracks = props.UnusedTracks
		local facs = props.UnusedFacs

		local trackTheme = theme.trackTheme

		local textWidth = StringUtils.getTextWidth(name, trackTheme.textSize, theme.font)
		local showTrackButton = (tracks and not isEmpty(tracks)) or (facs and not isEmpty(facs))

		return Roact.createElement(TrackListEntry, {
			Height = Constants.SUMMARY_TRACK_HEIGHT,
			Indent = 1,
			LayoutOrder = layoutOrder,
			Primary = true,
		}, {
			NameLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,

				Text = name,
				Font = theme.font,
				TextSize = trackTheme.textSize,
				TextColor3 = trackTheme.textColor,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			IKController = Roact.createElement(IKController, {
				Position = UDim2.new(0, textWidth + PADDING, 0.5, 0),
			}),

			AddTrackButton = (GetFFlagFacialAnimationSupport() and showTrackButton or (tracks and not isEmpty(tracks))) and Roact.createElement(AddTrackButton, {
				Size = UDim2.new(0, Constants.TRACKLIST_BUTTON_SIZE, 0, Constants.TRACKLIST_BUTTON_SIZE),
				Position = UDim2.new(1, -Constants.TRACKLIST_RIGHT_PADDING, 0.5, 0),
				Tracks = tracks,
				Facs = facs,
				OnTrackSelected = self.onTrackAdded,
			}),
		})
end

ContextServices.mapToProps(SummaryTrack, {
	Theme = ContextServices.Theme,
})


return SummaryTrack