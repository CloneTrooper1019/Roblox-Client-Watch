--[[
	Provides a base implementation of style tables for the Framework
	that are completely empty and only used so that the Framework
	can run for testing.

	StudioFrameworkStyles extends this style table to implement
	default values for Studio plugins.
]]

local FFlagTextInputDialogDevFramework = game:GetFastFlag("TextInputDialogDevFramework")
local FFlagDevFrameworkCheckbox = game:GetFastFlag("DevFrameworkCheckbox")

local function newDefaults()
	return {
		Default = {},
	}
end

local FrameworkStyles = {}
function FrameworkStyles.new()
	return {
		Common = newDefaults(),

		-- UI Styles
		Box = newDefaults(),
		BulletList = newDefaults(),
		Button = newDefaults(),
		Checkbox = FFlagDevFrameworkCheckbox and newDefaults() or nil,
		DropdownMenu = newDefaults(),
		DropShadow = newDefaults(),
		IconButton = newDefaults(),
		Image = newDefaults(),
		InfiniteScrollingFrame = newDefaults(),
		InstanceTreeView = newDefaults(),
		LinkText = newDefaults(),
		LoadingBar = newDefaults(),
		LoadingIndicator = newDefaults(),
		MultiLineTextInput = newDefaults(),
		Pane = newDefaults(),
		PageNavigation = newDefaults(),
		PaginatedTable = newDefaults(),
		RadioButton = newDefaults(),
		RadioButtonList = newDefaults(),
		RangeSlider = newDefaults(),
		RoundBox = newDefaults(),
		ScrollingFrame = newDefaults(),
		SelectInput = newDefaults(),
		Separator = newDefaults(),
		SimpleTab = newDefaults(),
		TableRow = newDefaults(),
		Slider = newDefaults(),
		Table = newDefaults(),
		Tabs = newDefaults(),
		TextInput = newDefaults(),
		TextInputDialog = FFlagTextInputDialogDevFramework and newDefaults() or nil,
		TextInputWithBottomText = newDefaults(),
		TextLabel = newDefaults(),
		TextWithInlineLink = newDefaults(),
		ToggleButton = newDefaults(),
		Tooltip = newDefaults(),
		TreeTable = newDefaults(),
		TreeView = newDefaults(),

		-- StudioUI Styles
		AssetPreview = newDefaults(),
		AssetRender = newDefaults(),
		Favorites = newDefaults(),
		MediaPlayerControls = newDefaults(),
		SearchBar = newDefaults(),
		StatelessAudioPlayer = newDefaults(),
		StatelessVideoPlayer = newDefaults(),
		StyledDialog = newDefaults(),
		TitledFrame = newDefaults(),
		VoteBar = newDefaults(),
		Votes = newDefaults(),
	}
end

return FrameworkStyles
