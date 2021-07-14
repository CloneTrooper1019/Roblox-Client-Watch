--[[
	Used to send Analytics events.
	We can define functions here for each event in the plugin,
	using self.Senders to send the events. In this way, events
	will automatically mock for testing.

	To log analytics events to the console, enable the LogAnalytics
	debug flag boolean in the workspace.
]]

local TARGET = "studio"
local CONTEXT = "animationEditor"

local Plugin = script.Parent.Parent.Parent
local UILibrary = require(Plugin.UILibrary)
local DebugFlags = require(Plugin.SrcDeprecated.Util.DebugFlags)

local Senders = UILibrary.Studio.Analytics

local Analytics = {}
Analytics.__index = Analytics

function Analytics.new()
	local self = {
		Senders = Senders.new({
			Target = TARGET,
			Context = CONTEXT,
			LogEvents = DebugFlags.LogAnalytics(),
		}),
		openedTimestamp = os.time(),
		ikOpenedTimestamp = os.time(),
	}
	setmetatable(self, Analytics)
	return self
end

function Analytics.mock()
	local self = {
		Senders = Senders.mock({
			Target = TARGET,
			Context = CONTEXT,
			LogEvents = DebugFlags.LogAnalytics(),
		}),
		openedTimestamp = os.time(),
		ikOpenedTimestamp = os.time(),
	}
	setmetatable(self, Analytics)
	return self
end

local function makeStatName(name)
	return TARGET .."." ..CONTEXT .."." ..name
end

function Analytics:update()
	self.Senders.logEvents = DebugFlags.LogAnalytics()
end

function Analytics:onEditorOpened(timelineUnit, keyframeSnap)
	self:update()
	self.openedTimestamp = os.time()
	self.Senders:sendEventDeferred("toolOpened", {
		method = 1,
		timelineUnit = timelineUnit,
		keyframeSnap = keyframeSnap,
	})
	self.Senders:reportCounter(makeStatName("EditorOpened"))
end

function Analytics:onEditorClosed()
	self:update()
	local timeOpen = os.time() - self.openedTimestamp
	self.Senders:sendEventDeferred("toolClosed", {
		timeOpen = timeOpen,
		method = 1,
	})
end

function Analytics:onImportAnimation(animationId)
	self:update()
	self.Senders:sendEventDeferred("importAnimation", {
		animationId = animationId,
	})
end

function Analytics:onImportFbxAnimation()
	self:update()
	self.Senders:sendEventDeferred("importFbxAnimation", {})
	self.Senders:reportCounter(makeStatName("FBXAnimationImported"))
end

function Analytics:onExportAnimation()
	self:update()
	self.Senders:sendEventDeferred("exportAnimation", {})
end

function Analytics:onLoadAnimation(name, numKeyframes, numPoses, numEvents)
	self:update()
	self.Senders:sendEventDeferred("loadAnimation", {
		name = name,
		numKeyframes = numKeyframes,
		numPoses = numPoses,
		numEvents = numEvents,
	})
end

function Analytics:onSaveAnimation(name, numKeyframes, numPoses, numEvents)
	self:update()
	self.Senders:sendEventDeferred("saveAnimation", {
		name = name,
		numKeyframes = numKeyframes,
		numPoses = numPoses,
		numEvents = numEvents,
	})
	self.Senders:reportStats(makeStatName("ExportedKeyframes"), numKeyframes)
	self.Senders:reportStats(makeStatName("ExportedPoses"), numPoses)
	self.Senders:reportStats(makeStatName("ExportedEvents"), numEvents)
end

function Analytics:onCreateNewAnimation(name)
	self:update()
	self.Senders:sendEventDeferred("createNewAnimation", {
		name = name,
	})
end

function Analytics:onQuantizeSelection(didQuantize)
	self:update()
	self.Senders:sendEventDeferred("quantizeSelection", {
		didQuantize = didQuantize,
	})
end

function Analytics:onTimeUnitChanged(timeUnit)
	self:update()
	self.Senders:sendEventDeferred("timeUnitChanged", {
		timeUnit = timeUnit,
	})
end

function Analytics:onKeyframeSnapChanged(keyframeSnap)
	self:update()
	self.Senders:sendEventDeferred("keyframeSnapChanged", {
		keyframeSnap = keyframeSnap,
	})
end

function Analytics:onToolChanged(tool)
	self:update()
	self.Senders:sendEventDeferred("toolChanged", {
		tool = tool,
	})
end

function Analytics:onIkEnabled()
	self:update()
	self.ikOpenedTimestamp = os.time()
	self.Senders:sendEventDeferred("ikEnabled", {})
	self.Senders:reportCounter(makeStatName("IKEnabled"))
end

function Analytics:onIkDisabled()
	self:update()
	local timeOpen = os.time() - self.ikOpenedTimestamp
	self.Senders:sendEventDeferred("ikDisabled", {
		timeOpen = timeOpen,
	})
end

function Analytics:onControlPressed(control)
	self:update()
	self.Senders:sendEventDeferred("controlPressed", {
		control = control,
	})
end

function Analytics:onTrackAdded(trackName, wasManual)
	self:update()
	self.Senders:sendEventDeferred("trackAdded", {
		trackName = trackName,
	})
end

function Analytics:onTrackDeleted(trackName, hadKeyframes)
	self:update()
	self.Senders:sendEventDeferred("trackDeleted", {
		trackName = trackName,
		hadKeyframes = hadKeyframes,
	})
end

function Analytics:onTrackSelected(trackName, source)
	self:update()
	self.Senders:sendEventDeferred("trackSelected", {
		trackName = trackName,
		source = source,
	})
end

function Analytics:onRenameKeyframe(name)
	self:update()
	self.Senders:sendEventDeferred("renameKeyframe", {
		name = name,
	})
end

function Analytics:onAddEvent(name, parameter)
	self:update()
	self.Senders:sendEventDeferred("addEvent", {
		name = name,
		parameter = parameter,
	})
	self.Senders:reportCounter(makeStatName("EventAdded"))
end

function Analytics:onAddKeyframe(trackName, frame)
	self:update()
	self.Senders:sendEventDeferred("addKeyframe", {
		trackName = trackName,
		frame = frame,
	})
	self.Senders:reportCounter(makeStatName("KeyframeAdded"))
end

function Analytics:onDeleteKeyframe(trackName, frame)
	self:update()
	self.Senders:sendEventDeferred("deleteKeyframe", {
		trackName = trackName,
		frame = frame,
	})
end

return Analytics