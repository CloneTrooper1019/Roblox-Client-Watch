-- Return an empty table to test with all flags off i.e. the UIBloxDefaultConfig
-- return {}

return {
	-- enableAlertTitleIconConfig: turning this on allows the Alert component to take
	-- in an optional titleIcon prop, which displays an icon above the Alert's title.
	enableAlertTitleIconConfig = true,

	--enableExperimentalGamepadSupport: Enables support of gamepad navigation via the roact-gamepad
	-- library. This is currently experimental and not yet ready for release.
	enableExperimentalGamepadSupport = true,

	--useNewUICornerRoundedCorners: Uses the new roblox CornerUI Instance instead of mask-based UI corners
	useNewUICornerRoundedCorners = true,

	-- emptyStateControllerSupport: Enables controller support for the EmptyState component.
	emptyStateControllerSupport = true,

	-- enableAlertCustomTitleFooterConfig: Enables custom title and footer content for the Alert
	enableAlertCustomTitleFooterConfig = true,

	-- hideHorizontalCarouselScrollButtonFix: Enables fix to hide the scroll right button for the
	-- HorizontalCarousel when all items are visible.
	hideHorizontalCarouselScrollButtonFix = true,

	-- tooltipWidthUsesHeaderToo: Turn on fix for tooltip which calculates the width of the container
	-- based on the body and title text width.
	tooltipWidthUsesHeaderToo = true,

	-- useAnimatedXboxCursors: Uses the new animated selection cursors when selecting UI elements in xbox
	useAnimatedXboxCursors = true,

	-- useUpdatedCheckbox: Enables FitFrame for InputButton and gives Checkbox a gamepad
	-- selection cursor.
	useUpdatedCheckbox = true,

	-- fixDropdownMenuListPositionAndSize: Uses the bottom inset for positioning the dropdown menu list for
	-- mobile view, allows sizing relative to parent container size, and limits dropdown width for wide view.
	fixDropdownMenuListPositionAndSize = true,
}
