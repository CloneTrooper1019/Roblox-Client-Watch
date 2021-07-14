--[[
	A player for videos that displays a video and controls.

	Required Props:
		string VideoId: The ID of the video to play. (should be prefixed with rbxassetid://)

	Optional Props:
		callback OnPause: Called when the video is paused.
		callback OnPlay: Called when the video plays.
		number LayoutOrder: The LayoutOrder of the component.
		UDim2 Position: The Position of the component.
		Style Style: The styling for the component.
]]

local Framework = script.Parent.Parent

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck

local MediaPlayerWrapper = require(script.Parent.MediaPlayerWrapper)
local StatelessVideoPlayer = require(script.Parent.StatelessVideoPlayer)

local VideoPlayer = MediaPlayerWrapper(StatelessVideoPlayer)

Typecheck.wrap(VideoPlayer, script)

return VideoPlayer