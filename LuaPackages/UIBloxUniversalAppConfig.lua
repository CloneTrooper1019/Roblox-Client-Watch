-- See https://confluence.rbx.com/display/MOBAPP/UIBlox+Flagging
-- for more info on how to add values here
local CorePackages = game:GetService("CorePackages")

local GetFFlagLuaAppUseNewUIBloxRoundedCorners = require(CorePackages.UIBloxFlags.GetFFlagLuaAppUseNewUIBloxRoundedCorners)
local GetFFlagUIBloxHideHorizontalCarouselScrollButtonFix = require(CorePackages.UIBloxFlags.GetFFlagUIBloxHideHorizontalCarouselScrollButtonFix)
local FFlagUIBloxSlidersFilterOldTouchInputs = require(CorePackages.UIBloxFlags.FFlagUIBloxSlidersFilterOldTouchInputs)
local FFlagUIBloxEmptyStateControllerSupport = require(CorePackages.UIBloxFlags.FFlagUIBloxEmptyStateControllerSupport)
local GetFFlagUIBloxUseHeaderBarV2 = require(CorePackages.UIBloxFlags.GetFFlagUIBloxUseHeaderBarV2)
local FFlagUIBloxUseTileThumbnailV2 = require(CorePackages.UIBloxFlags.FFlagUIBloxUseTileThumbnailV2)
local FFlagUseUpdatedUIBloxCheckbox = require(CorePackages.UIBloxFlags.FFlagUseUpdatedUIBloxCheckbox)
local FFlagTempFixEmptyGridView = require(CorePackages.UIBloxFlags.FFlagTempFixEmptyGridView)
local FFlagUIBloxGridViewIsMountedCleanup = require(CorePackages.UIBloxFlags.FFlagUIBloxGridViewIsMountedCleanup)
local FFlagNoSpawnInGridViewHandler = require(CorePackages.UIBloxFlags.FFlagNoSpawnInGridViewHandler)
local GetFFlagUIBloxFixDropdownMenuListPositionAndSize = require(CorePackages.UIBloxFlags.GetFFlagUIBloxFixDropdownMenuListPositionAndSize)
local GetFFlagUIBloxVerticalScrollViewAutomaticCanvasSize = require(CorePackages.UIBloxFlags.GetFFlagUIBloxVerticalScrollViewAutomaticCanvasSize)
local GetFFlagUIBloxStyleRefactor = require(CorePackages.UIBloxFlags.GetFFlagUIBloxStyleRefactor)

return {
	tempFixEmptyGridView = FFlagTempFixEmptyGridView,
	noSpawnInGridViewHandler = FFlagNoSpawnInGridViewHandler,
	gridViewIsMountedCleanup = FFlagUIBloxGridViewIsMountedCleanup,
	useNewUICornerRoundedCorners = GetFFlagLuaAppUseNewUIBloxRoundedCorners(),
	enableExperimentalGamepadSupport = true,
	genericSliderFilterOldTouchInputs = FFlagUIBloxSlidersFilterOldTouchInputs,
	allowSystemBarToAcceptString = game:DefineFastFlag("UIBloxAllowSystemBarToAcceptString", false),
	emptyStateControllerSupport = FFlagUIBloxEmptyStateControllerSupport,
	useHeaderBarV2 = GetFFlagUIBloxUseHeaderBarV2(),
	useTileThumbnailV2 = FFlagUIBloxUseTileThumbnailV2,
	tooltipWidthUsesHeaderToo = game:DefineFastFlag("UIBloxTooltipWidthUsesHeaderToo", false),
	useAnimatedXboxCursors = game:DefineFastFlag("GamepadAnimatedCursor", false),
	enableAlertCustomTitleFooterConfig = game:DefineFastFlag("UIBloxEnableAlertCustomTitleFooterConfig", false),
	hideHorizontalCarouselScrollButtonFix = GetFFlagUIBloxHideHorizontalCarouselScrollButtonFix(),
	useUpdatedCheckbox = FFlagUseUpdatedUIBloxCheckbox,
	fixDropdownMenuListPositionAndSize = GetFFlagUIBloxFixDropdownMenuListPositionAndSize(),
	enabledAutomaticCanvasSizePropForVerticalScrollView = GetFFlagUIBloxVerticalScrollViewAutomaticCanvasSize(),
	styleRefactorConfig = GetFFlagUIBloxStyleRefactor(),
}
