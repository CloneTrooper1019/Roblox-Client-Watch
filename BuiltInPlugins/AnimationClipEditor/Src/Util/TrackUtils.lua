--[[
	Utility functions for dope sheet tracks to use to help
	create Keyframe components and place them onscreen.
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)
local KeyframeUtils = require(Plugin.Src.Util.KeyframeUtils)
local Constants = require(Plugin.Src.Util.Constants)

local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

local TrackUtils = {}

local function removeNegativeZero(val)
	if val == 0 then
		return math.abs(val)
	else
		return val
	end
end

-- Performs a visiting function on each keyframe between the range
-- startFrame and endFrame, inclusive. For each keyframe within the range,
-- visitFunc provides the frame number and the keyframe at that frame.
function TrackUtils.traverseFrameRange(keyframes, startFrame, endFrame, func)
	local first, first2 = KeyframeUtils.findNearestKeyframes(keyframes, startFrame)
	local last = KeyframeUtils.findNearestKeyframes(keyframes, endFrame)
	local firstIndex = first2 and first2 or first
	local lastIndex = last

	for keyIndex = firstIndex, lastIndex do
		local frame = keyframes[keyIndex]
		if frame >= startFrame and frame <= endFrame then
			func(frame, keyframes[keyIndex])
		end
	end
end

-- Gets the summary keyframes between startFrame and endFrame for tracks.
-- selectedKeyframes and previewing are optional parameters.
-- selectedKeyframes is used to find which summary keyframes are selected, and
-- previewing is used to determine if the user is currently moving keyframes.
function TrackUtils.getSummaryKeyframes(tracks, startFrame, endFrame, selectedKeyframes, previewing)
	local foundFrames = {}
	local selectedFrames = {}

	for _, track in pairs(tracks) do
		local instance = track.Instance
		local name = track.Name
		local keyframes = track.Keyframes

		if keyframes then
			TrackUtils.traverseFrameRange(keyframes, startFrame, endFrame, function(frame)
				local selected = selectedKeyframes and selectedKeyframes[instance]
					and selectedKeyframes[instance][name]
					and selectedKeyframes[instance][name][frame]

				if not (selected and previewing) then
					foundFrames[frame] = true
					if selected then
						selectedFrames[frame] = true
					end
				end
			end)
		end
	end

	local frames = Cryo.Dictionary.keys(foundFrames)
	return frames, selectedFrames
end

function TrackUtils.getScaledKeyframePosition(frame, startFrame, endFrame, width)
	return math.floor((frame - startFrame) * width / (endFrame - startFrame))
end

function TrackUtils.getKeyframeFromPosition(position, startFrame, endFrame, trackLeft, trackWidth)
	local timelineScale = trackWidth / (endFrame - startFrame)
	local xposInTimeline = position.X - trackLeft
	local frame = startFrame + xposInTimeline / timelineScale
	return KeyframeUtils.getNearestFrame(frame)
end

function TrackUtils.countVisibleKeyframes(keyframes, startFrame, endFrame)
	local startIndex, endIndex = TrackUtils.getKeyframesExtents(keyframes, startFrame, endFrame)
	if startIndex == endIndex then
		local hasKeyframe = KeyframeUtils.findKeyframe(keyframes, startFrame)
			or KeyframeUtils.findKeyframe(keyframes, endFrame)
		return hasKeyframe ~= nil and 1 or 0
	else
		return endIndex - startIndex + 1
	end
end

function TrackUtils.getKeyframesExtents(keyframes, startFrame, endFrame)
	local first, second = KeyframeUtils.findNearestKeyframes(keyframes, startFrame)
	local startIndex, endIndex
	if second ~= nil then
		startIndex = second
	else
		startIndex = first
	end
	endIndex = KeyframeUtils.findNearestKeyframes(keyframes, endFrame)

	if startIndex and endIndex and keyframes[startIndex] >= startFrame and keyframes[endIndex] >= startFrame then
		return startIndex, endIndex
	end
end

-- Returns the expanded size of a track based on its type.
function TrackUtils.getExpandedSize(track)
	local trackType = track.Type
	if trackType == Constants.TRACK_TYPES.CFrame then
		return 3
	else
		return 2
	end
end

-- Returns the default value for a new keyframe based on a track type.
function TrackUtils.getDefaultValueByType(trackType)
	if trackType == Constants.TRACK_TYPES.CFrame then
		return CFrame.new()
	elseif trackType == Constants.TRACK_TYPES.Facs then
		return 0
	end
end

if GetFFlagFacialAnimationSupport() then
	function TrackUtils.getDefaultValue(track)
		if track and track.Type then
			return TrackUtils.getDefaultValueByType(track.Type)
		end
	end
else
	function TrackUtils.getDefaultValue(track)
		if track and track.Type then
			local trackType = track.Type
			if trackType == Constants.TRACK_TYPES.CFrame then
				return CFrame.new()
			end
		else
			return CFrame.new()
		end
	end
end

-- Given a track name and a list of trackEntries, find the
-- type of the corresponding track
function TrackUtils.getTrackTypeFromName(trackName, tracks)
	for _, track in pairs(tracks) do
		if track.Name == trackName then
			return track.Type
		end
	end
end

-- Given a vertical position yPos in the dope sheet, finds which track
-- is at that position.
function TrackUtils.getTrackFromPosition(tracks, topTrackIndex, yPos)
	local trackIndex = math.max(0, topTrackIndex - 1)
	yPos = yPos - Constants.SUMMARY_TRACK_HEIGHT
	local numTracks = #tracks

	for index, track in ipairs(tracks) do
		if index >= topTrackIndex then
			if yPos <= 0 then
				break
			end

			trackIndex = trackIndex + 1

			if track.Expanded then
				yPos = yPos - Constants.TRACK_HEIGHT * TrackUtils.getExpandedSize(track)
			else
				yPos = yPos - Constants.TRACK_HEIGHT
			end
		end
	end

	-- If yPos is still positive after passing all tracks, it is off
	-- the bottom of the dope sheet.
	if yPos / Constants.TRACK_HEIGHT > 0 then
		return numTracks + 1
	elseif trackIndex == topTrackIndex - 1 then
		-- Summary track
		return 0
	else
		return math.max(0, trackIndex)
	end
end

function TrackUtils.getTrackIndex(tracks, trackName)
	for index, track in ipairs(tracks) do
		if trackName == track.Name then
			return index
		end
	end
end

function TrackUtils.getTrackYPosition(tracks, topTrackIndex, trackIndex)
	local yPos = Constants.SUMMARY_TRACK_HEIGHT

	local index = topTrackIndex
	while index < trackIndex do
		local currentTrack = tracks[index]
		if currentTrack.Expanded then
			yPos = yPos + Constants.TRACK_HEIGHT * TrackUtils.getExpandedSize(currentTrack)
		else
			yPos = yPos + Constants.TRACK_HEIGHT
		end
		index = index + 1
	end

	return yPos
end

function TrackUtils.getCurrentValue(track, frame, animationData)
	local name = track.Name
	local instance = track.Instance

	local currentValue
	local currentTrack = animationData.Instances[instance].Tracks[name]
	if currentTrack then
		currentValue = KeyframeUtils:getValue(currentTrack, frame)
	else
		currentValue = TrackUtils.getDefaultValue(track)
	end

	return currentValue
end

function TrackUtils.getItemsForProperty(track, value)
	local trackType = track.Type
	local properties = Constants.PROPERTY_KEYS
	local items = {}

	if trackType == Constants.TRACK_TYPES.CFrame then
		local position = value.Position
		local xRot, yRot, zRot = value:ToEulerAnglesXYZ()
		items = {
			Position = {
				{
					Name = properties.X,
					Key = "X",
					Value = position.X,
				},
				{
					Name = properties.Y,
					Key = "Y",
					Value = position.Y,
				},
				{
					Name = properties.Z,
					Key = "Z",
					Value = position.Z,
				},
			},
			Rotation = {
				{
					Name = properties.X,
					Key = "X",
					Value = removeNegativeZero(math.deg(xRot)),
				},
				{
					Name = properties.Y,
					Key = "Y",
					Value = removeNegativeZero(math.deg(yRot)),
				},
				{
					Name = properties.Z,
					Key = "Z",
					Value = removeNegativeZero(math.deg(zRot)),
				},
			},
		}
	elseif trackType == Constants.TRACK_TYPES.Facs then
		items = {
			{
				Name = "V",
				Key = "Value",
				Value = value,
			},
		}
	end

	return items
end

function TrackUtils.getPropertyForItems(track, items)
	local trackType = track.Type
	local value

	if trackType == Constants.TRACK_TYPES.CFrame then
		local position = items.Position
		local rotation = items.Rotation
		local xRot = math.rad(rotation[1].Value)
		local yRot = math.rad(rotation[2].Value)
		local zRot = math.rad(rotation[3].Value)
		value = CFrame.new(position[1].Value, position[2].Value, position[3].Value)
			* CFrame.fromEulerAnglesXYZ(xRot, yRot, zRot)
	end

	return value
end

function TrackUtils.getZoomRange(animationData, scroll, zoom, editingLength)
	local range = {}
	local startFrame = animationData.Metadata.StartFrame
	local endFrame = math.max(animationData.Metadata.EndFrame, editingLength)
	local maxLength = animationData.Metadata.FrameRate * Constants.MAX_TIME

	local length = endFrame - startFrame
	local lengthWithPadding = length * Constants.LENGTH_PADDING
	lengthWithPadding = math.min(lengthWithPadding, maxLength)

	local zoomedLength = lengthWithPadding * (1 - zoom)
	zoomedLength = math.max(zoomedLength, 1)

	range.Start = startFrame + (lengthWithPadding - zoomedLength) * scroll
	range.End = range.Start + zoomedLength

	return range
end

return TrackUtils