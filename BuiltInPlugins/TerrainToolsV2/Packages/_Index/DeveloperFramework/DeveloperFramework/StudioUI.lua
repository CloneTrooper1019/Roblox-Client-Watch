--[[
	Public interface for StudioUI
]]

local strict = require(script.Parent.Util.strict)

local StudioUI = strict({
	-- Default styles for the Framework
	StudioFrameworkStyles = require(script.StudioFrameworkStyles),
	Common = require(script.StudioFrameworkStyles.Common),

	-- PluginWidgets
	AssetRender = require(script.AssetRender),
	AssetPreview = require(script.AssetPreview),
	AudioPlayer = require(script.AudioPlayer),
	DockWidget = require(script.DockWidget),
	Dialog = require(script.Dialog),
	Favorites = require(script.Favorites),
	SearchBar = require(script.SearchBar),
	StyledDialog = require(script.StyledDialog),
	VideoPlayer = require(script.VideoPlayer),
	VoteBar = require(script.VoteBar),
	Votes = require(script.Votes),

	-- PluginButton
	PluginToolbar = require(script.PluginToolbar),
	PluginButton = require(script.PluginButton),

	TextInputWithBottomText = require(script.TextInputWithBottomText),
	TitledFrame = require(script.TitledFrame),
})

return StudioUI
