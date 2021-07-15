--[[
	A player for sounds that displays a still image and controls.

	Required Props:
		string SoundId: The ID of the sound to play. (should be prefixed with rbxassetid://)

	Optional Props:
		callback OnPause: Called when the sound is paused.
		callback OnPlay: Called when the sound plays.
		number LayoutOrder: The LayoutOrder of the component.
		UDim2 Position: The Position of the component.
		Style Style: The styling for the component.
]]

local Framework = script.Parent.Parent

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck

local MediaPlayerWrapper = require(script.Parent.MediaPlayerWrapper)
local StatelessAudioPlayer = require(script.Parent.StatelessAudioPlayer)

local AudioPlayer = MediaPlayerWrapper(StatelessAudioPlayer)

Typecheck.wrap(AudioPlayer, script)

return AudioPlayer