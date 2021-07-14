local StudioService = game:GetService("StudioService")
local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)
local TARGET = "studio"
local CONTEXT = "animationEditor"

return function(analyticsService)
	local function sendEvent(eventName, additionalArgs)
        additionalArgs = additionalArgs or {}

        local args = Cryo.Dictionary.join({
            studioSid = analyticsService:GetSessionId(),
            clientId = analyticsService:GetClientId(),
            placeId = game.PlaceId,
            userId = StudioService:GetUserId(),
        }, additionalArgs)

        analyticsService:SendEventDeferred("studio", "animationEditor", eventName, args)
	end

	local function reportCounter(counterName, count)
        analyticsService:ReportCounter(counterName, count or 1)
    end

    local function reportStats(statName, count)
        analyticsService:ReportStats(statName, count or 1)
    end

    local function makeStatName(name)
        return TARGET .."." ..CONTEXT .."." ..name
    end

    return {
        onEditorOpened = function (timelineUnit, keyframeSnap)
            sendEvent("toolOpened", {
                method = 1,
                timelineUnit = timelineUnit,
                keyframeSnap = keyframeSnap,
            })
            reportCounter(makeStatName("EditorOpened"))
            sendEvent("EditorOpened")
        end,

        onEditorClosed = function(timeOpen)
            sendEvent("toolClosed", {
                timeOpen = timeOpen,
                method = 1,
            })
        end,

        onImportAnimation = function(animationId)
            sendEvent("importAnimation", {
                animationId = animationId,
            })
        end,

        onImportFbxAnimation = function()
            sendEvent("importFbxAnimation", {})
            reportCounter(makeStatName("FBXAnimationImported"))
            sendEvent("FBXAnimationImported")
        end,

        onExportAnimation = function()
            sendEvent("exportAnimation", {})
        end,

        onLoadAnimation = function(name, numKeyframes, numPoses, numEvents)
            sendEvent("loadAnimation", {
                name = name,
                numKeyframes = numKeyframes,
                numPoses = numPoses,
                numEvents = numEvents,
            })
        end,

        onSaveAnimation = function(name, numKeyframes, numPoses, numEvents)
            sendEvent("saveAnimation", {
                name = name,
                numKeyframes = numKeyframes,
                numPoses = numPoses,
                numEvents = numEvents,
            })
            reportStats(makeStatName("ExportedKeyframes"), numKeyframes)
            reportStats(makeStatName("ExportedPoses"), numPoses)
            reportStats(makeStatName("ExportedEvents"), numEvents)
        end,

        onCreateNewAnimation = function(name)
            sendEvent("createNewAnimation", {
                name = name,
            })
        end,

        onQuantizeSelection = function(didQuantize)
            sendEvent("quantizeSelection", {
                didQuantize = didQuantize,
            })
        end,

        onTimeUnitChanged = function(timeUnit)
            sendEvent("timeUnitChanged", {
                timeUnit = timeUnit,
            })
        end,

        onKeyframeSnapChanged = function(keyframeSnap)
            sendEvent("keyframeSnapChanged", {
                keyframeSnap = keyframeSnap,
            })
        end,

        onToolChanged = function(tool)
            sendEvent("toolChanged", {
                tool = tool,
            })
        end,

        onIkEnabled = function()
            sendEvent("ikEnabled", {})
            reportCounter(makeStatName("IKEnabled"))
            sendEvent("IKEnabled")
        end,

        onIkDisabled = function(timeOpen)
            sendEvent("ikDisabled", {
                timeOpen = timeOpen,
            })
        end,

        onControlPressed = function(control)
            sendEvent("controlPressed", {
                control = control,
            })
        end,

        onTrackAdded = function(trackName, wasManual)
            sendEvent("trackAdded", {
                trackName = trackName,
            })
        end,

        onTrackDeleted = function(trackName, hadKeyframes)
            sendEvent("trackDeleted", {
                trackName = trackName,
                hadKeyframes = hadKeyframes,
            })
        end,

        onTrackSelected = function(trackName, source)
            sendEvent("trackSelected", {
                trackName = trackName,
                source = source,
            })
        end,

        onRenameKeyframe = function(name)
            sendEvent("renameKeyframe", {
                name = name,
            })
        end,

        onAddEvent = function(name, parameter)
            sendEvent("addEvent", {
                name = name,
                parameter = parameter,
            })
            reportCounter(makeStatName("EventAdded"))
            sendEvent("EventAdded")
        end,

        onAddKeyframe = function(trackName, frame)
            sendEvent("addKeyframe", {
                trackName = trackName,
                frame = frame,
            })
            reportCounter(makeStatName("KeyframeAdded"))
            sendEvent("KeyframeAdded")
        end,

        onDeleteKeyframe = function(trackName, frame)
            sendEvent("deleteKeyframe", {
                trackName = trackName,
                frame = frame,
            })
        end,
    }
end