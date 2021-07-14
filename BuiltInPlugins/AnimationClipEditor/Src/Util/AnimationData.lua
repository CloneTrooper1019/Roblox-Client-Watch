--[[
	Utilities for interacting with the AnimationEditor animation data format.

	Handles:
		-Creation of new AnimationData tables.
		-Exporting to and importing from CFrame[][]
			for interfacing with the Roblox API for animations.
		-Helper functions for keyframe manipulation thunks.
]]

local Plugin = script.Parent.Parent.Parent
local KeyframeUtils = require(Plugin.Src.Util.KeyframeUtils)
local TrackUtils = require(Plugin.Src.Util.TrackUtils)
local Templates = require(Plugin.Src.Util.Templates)
local Constants = require(Plugin.Src.Util.Constants)
local deepCopy = require(Plugin.Src.Util.deepCopy)
local isEmpty = require(Plugin.Src.Util.isEmpty)
local Cryo = require(Plugin.Packages.Cryo)

local AnimationData = {}

function AnimationData.new(name, frameRate, rootType)
	assert(name ~= nil, "Expected a name for the AnimationData.")
	assert(frameRate ~= nil, "Expected a frameRate for the AnimationData.")
	assert(frameRate > 0, "Expected frameRate to be positive.")

	local animationData = Templates.animationData()
	animationData.Metadata.Name = name
	animationData.Metadata.FrameRate = frameRate
	animationData.Instances.Root.Type = rootType
	return animationData
end

function AnimationData.newRigAnimation(name)
	return AnimationData.new(name, Constants.DEFAULT_FRAMERATE, Constants.INSTANCE_TYPES.Rig)
end

function AnimationData.toCFrameArray(bones, data, frameRate)
	assert(bones ~= nil, "No bones array was provided.")
	assert(data ~= nil, "No data table was provided.")
	assert(typeof(bones) == "table", "Bones should be an array of bone names.")
	assert(typeof(data) == "table", "Data must be an AnimationData table.")

	local inputFrameRate = data.Metadata.FrameRate
	local outputFrameRate = frameRate or inputFrameRate
	assert(outputFrameRate ~= nil, "No frame rate was found for exporting.")
	assert(inputFrameRate > 0, "Input frame rate must be positive.")
	assert(outputFrameRate > 0, "Output frame rate must be positive.")

	local inputLength = data.Metadata.EndFrame - data.Metadata.StartFrame
	local rateConversion = inputFrameRate / outputFrameRate
	local outputLength = inputLength / rateConversion

	local poses = {}

	local skeleton = data.Instances.Root
	assert(skeleton.Type == "Skeleton", "Can only export Skeleton animations to CFrame[][]")

	local tracks = skeleton.Tracks
	for boneIndex, boneName in ipairs(bones) do
		local keyframes = {}
		if tracks[boneName] then
			for frame = 1, outputLength do
				local value = KeyframeUtils:getValue(tracks[boneName], frame * rateConversion)
				keyframes[frame] = value
			end
		end
		poses[boneIndex] = keyframes
	end

	return poses
end

function AnimationData.fromCFrameArray(bones, poses, name, frameRate)
	assert(bones ~= nil, "No bones array was provided.")
	assert(typeof(bones) == "table", "Bones should be an array of bone names.")

	local animationData = AnimationData.new(name, frameRate)
	animationData.Instances.Root.Type = "Skeleton"
	local rootTracks = animationData.Instances.Root.Tracks

	for boneIndex, boneName in ipairs(bones) do
		if #poses[boneIndex] > 0 then
			rootTracks[boneName] = Templates.track(Constants.TRACK_TYPES.CFrame)
			animationData.Metadata.EndFrame = math.max(animationData.Metadata.EndFrame, #poses[boneIndex])
			for frame = 1, #poses[boneIndex] do
				table.insert(rootTracks[boneName].Keyframes, frame)
				local newKeyframe = Templates.keyframe()
				newKeyframe.Value = poses[boneIndex][frame]
				rootTracks[boneName].Data[frame] = newKeyframe
			end
		end
	end

	return animationData
end

-- Adds an event to the events table at the given frame,
-- with the given name and value.
function AnimationData.addEvent(events, frame, name, value)
	local eventKeyframes = events.Keyframes
	local eventData = events.Data
	if not eventData[frame] then
		local insertIndex = KeyframeUtils.findInsertIndex(eventKeyframes, frame)
		if insertIndex then
			table.insert(eventKeyframes, insertIndex, frame)
		end
		eventData[frame] = {}
	end
	if not eventData[frame][name] then
		eventData[frame][name] = value or ""
	end
end

-- Moves all events at a frame to a new frame.
function AnimationData.moveEvents(events, oldFrame, newFrame)
	if oldFrame == newFrame then
		return
	end

	local eventKeyframes = events.Keyframes
	local eventData = events.Data
	if eventData[oldFrame] then
		local oldIndex = KeyframeUtils.findKeyframe(eventKeyframes, oldFrame)
		table.remove(eventKeyframes, oldIndex)

		local insertIndex = KeyframeUtils.findInsertIndex(eventKeyframes, newFrame)
		if insertIndex then
			table.insert(eventKeyframes, insertIndex, newFrame)
		end
		eventData[newFrame] = deepCopy(eventData[oldFrame])
		eventData[oldFrame] = nil
	end
end

-- Deletes all events at the given frame.
function AnimationData.deleteEvents(events, frame)
	local eventKeyframes = events.Keyframes
	local eventData = events.Data
	if eventData[frame] then
		local oldIndex = KeyframeUtils.findKeyframe(eventKeyframes, frame)
		table.remove(eventKeyframes, oldIndex)
		eventData[frame] = nil
	end
end

-- Edits the value of the event at the given frame and name.
function AnimationData.setEventValue(events, frame, name, value)
	local eventData = events.Data
	if eventData[frame] and eventData[frame][name] then
		eventData[frame][name] = value
	end
end

-- Removes an event at frame and name from the events table.
function AnimationData.removeEvent(events, frame, name)
	local eventKeyframes = events.Keyframes
	local eventData = events.Data
	if eventData[frame] and eventData[frame][name] then
		eventData[frame][name] = nil
		if isEmpty(eventData[frame]) then
			eventData[frame] = nil
			local keyIndex = KeyframeUtils.findKeyframe(eventKeyframes, frame)
			table.remove(eventKeyframes, keyIndex)
		end
	end
end

-- Adds a new track at trackName to the given track.
function AnimationData.addTrack(tracks, trackName, trackType)
	tracks[trackName] = Templates.track(trackType)
end

-- Adds a new keyframe at the given frame with the given value.
function AnimationData.addKeyframe(track, frame, value)
	local trackKeyframes = track.Keyframes
	local insertIndex = KeyframeUtils.findInsertIndex(trackKeyframes, frame)
	if insertIndex then
		table.insert(trackKeyframes, insertIndex, frame)
		track.Data[frame] = Templates.keyframe()
		track.Data[frame].Value = value
	end
end

function AnimationData.addDefaultKeyframe(track, frame, trackType)
	local value = TrackUtils.getDefaultValueByType(trackType)
	AnimationData.addKeyframe(track, frame, value)
end

-- Finds a named keyframe at oldFrame and moves it to newFrame if it exists
-- and if no more keyframes would exist at the old name.
function AnimationData.moveNamedKeyframe(data, oldFrame, newFrame)
	if data.Events then
		local namedKeyframes = data.Events.NamedKeyframes
		if namedKeyframes and namedKeyframes[oldFrame] then
			local oldName = namedKeyframes[oldFrame]
			local shouldMove = true
			for _, instance in pairs(data.Instances) do
				local summaryKeyframes = TrackUtils.getSummaryKeyframes(instance.Tracks,
					data.Metadata.StartFrame, data.Metadata.EndFrame)
				for _, frame in ipairs(summaryKeyframes) do
					if frame == oldFrame then
						shouldMove = false
					end
				end
			end
			if shouldMove then
				AnimationData.setKeyframeName(data, oldFrame, nil)
				AnimationData.setKeyframeName(data, newFrame, oldName)
			end
		end
	end
end

-- Moves a keyframe from oldFrame to newFrame.
function AnimationData.moveKeyframe(track, oldFrame, newFrame)
	if oldFrame == newFrame then
		return
	end

	local trackKeyframes = track.Keyframes
	local oldIndex = KeyframeUtils.findKeyframe(trackKeyframes, oldFrame)
	table.remove(trackKeyframes, oldIndex)

	local insertIndex = KeyframeUtils.findInsertIndex(trackKeyframes, newFrame)
	if insertIndex then
		table.insert(trackKeyframes, insertIndex, newFrame)
	end

	track.Data[newFrame] = deepCopy(track.Data[oldFrame])
	track.Data[oldFrame] = nil
end

-- Deletes the keyframe at the given track and frame.
function AnimationData.deleteKeyframe(track, frame)
	track.Data[frame] = nil
	local index = KeyframeUtils.findKeyframe(track.Keyframes, frame)
	table.remove(track.Keyframes, index)
end

-- Sets the data for the keyframe at the given track and frame.
function AnimationData.setKeyframeData(track, frame, data)
	track.Data[frame] = Cryo.Dictionary.join(track.Data[frame], data)
end

-- Renames a summary keyframe in the animation.
function AnimationData.setKeyframeName(data, frame, name)
	if name == Constants.DEFAULT_KEYFRAME_NAME then
		data.Events.NamedKeyframes[frame] = nil
	else
		data.Events.NamedKeyframes[frame] = name
	end
end

-- Removes summary keyframe names which are no longer attached to keyframes
function AnimationData.validateKeyframeNames(data)
	if data.Events then
		local namedKeyframes = data.Events.NamedKeyframes
		if namedKeyframes and not isEmpty(namedKeyframes) then
			local validFrames = {}
			for _, instance in pairs(data.Instances) do
				local summaryKeyframes = TrackUtils.getSummaryKeyframes(instance.Tracks,
					data.Metadata.StartFrame, data.Metadata.EndFrame)
				for _, frame in ipairs(summaryKeyframes) do
					validFrames[frame] = true
				end
			end
			for frame, _ in pairs(namedKeyframes) do
				if not validFrames[frame] then
					AnimationData.setKeyframeName(data, frame, nil)
				end
			end
		end
	end
end

function AnimationData.setEndFrame(data)
	local endFrame = 0
	if data and data.Instances then
		for _, instance in pairs(data.Instances) do
			if instance.Tracks then
				for _, track in pairs(instance.Tracks) do
					if track.Keyframes then
						local lastKey = track.Keyframes[#track.Keyframes]
						endFrame = math.max(endFrame, lastKey)
					end
				end
			end
		end
	end
	data.Metadata.EndFrame = endFrame
end

function AnimationData.getMaximumLength(framerate)
	return framerate * Constants.MAX_TIME
end

function AnimationData.setLooping(data, looping)
	if data then
		data.Metadata.Looping = looping
	end
end

-- Used to check whether an animation has keyframes in between frames.
-- If all keyframes are on frames at 30 FPS, this will return true.
function AnimationData.isQuantized(data)
	if data and data.Instances then
		for _, instance in pairs(data.Instances) do
			for _, track in pairs(instance.Tracks) do
				for _, keyframe in ipairs(track.Keyframes) do
					if keyframe ~= math.floor(keyframe) then
						return false
					end
				end
			end
		end
		return true
	end
end

-- removes all keyframes that exist past the maximum animation
-- time allowed, returns true if keyframes were removed.
function AnimationData.removeExtraKeyframes(data)
	local removed = false

	if data and data.Instances and data.Metadata then
		local maxLength = AnimationData.getMaximumLength(data.Metadata.FrameRate)

		-- first pass: remove keyframes
		local keysToRemove = {}

		-- get range of keyframe indices past max frame limit
		for instanceName, instance in pairs(data.Instances) do
			keysToRemove[instanceName] = {}
			for trackName, track in pairs(instance.Tracks) do
				local minIndex = KeyframeUtils.findNearestKeyframes(track.Keyframes, maxLength)
				keysToRemove[instanceName][trackName] = {
					Start = minIndex,
					End = #track.Keyframes,
				}
			end
		end

		-- remove each keyframe in range
		for instance, tracks in pairs(keysToRemove) do
			for track, range in pairs(tracks) do
				for i = range.End, range.Start, -1 do
					local keyframes = data.Instances[instance].Tracks[track].Keyframes
					local kfData = data.Instances[instance].Tracks[track].Data
					local frame = keyframes[i]
					if frame > maxLength then
						removed = true
						kfData[frame] = nil
						table.remove(keyframes, i)
					end
				end
			end
		end

		-- second pass: remove events
		if data.Events and data.Events.Keyframes then
			local eventsToRemove = {}
			for _, frame in ipairs(data.Events.Keyframes) do
				if frame > maxLength then
					removed = true
					table.insert(eventsToRemove, frame)
				end
			end

			for _, frame in ipairs(eventsToRemove) do
				AnimationData.deleteEvents(data.Events, frame)
			end
		end
	end

	return removed
end

function AnimationData.getSelectionBounds(data, selectedKeyframes)
	if not selectedKeyframes or isEmpty(selectedKeyframes) then
		return nil, nil
	end

	local earliest = AnimationData.getMaximumLength(data.Metadata.FrameRate)
	local latest = 0
	for _, instance in pairs(selectedKeyframes) do
		for trackName, _ in pairs(instance) do
			local keyframes = Cryo.Dictionary.keys(instance[trackName])
			table.sort(keyframes)
			if keyframes then
				if keyframes[1] <= earliest then
					earliest = keyframes[1]
				end
				if keyframes[#keyframes] >= latest then
					latest = keyframes[#keyframes]
				end
			end
		end
	end
	return earliest, latest
end

function AnimationData.getEventBounds(animationData, selectedEvents)
	local earliest = AnimationData.getMaximumLength(animationData.Metadata.FrameRate)
	local latest = 0
	local eventFrames = Cryo.Dictionary.keys(selectedEvents)
	table.sort(eventFrames)
	if eventFrames then
		if eventFrames[1] <= earliest then
			earliest = eventFrames[1]
		end
		if eventFrames[#eventFrames] >= latest then
			latest = eventFrames[#eventFrames]
		end
	end
	return earliest, latest
end

return AnimationData