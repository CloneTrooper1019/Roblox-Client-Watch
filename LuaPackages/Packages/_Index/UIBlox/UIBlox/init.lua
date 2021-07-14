local makeConfigurable = require(script.Core.Config.makeConfigurable)
local UIBloxDefaultConfig = require(script.UIBloxDefaultConfig)
local Packages = script.Parent

local function initializeLibrary(configs)
	local strict = require(script.Utility.strict)

	local UIBlox = {}

	UIBlox.Core = strict({
		Animation = strict({
			SpringAnimatedItem = require(script.Utility.SpringAnimatedItem),
			withAnimation = require(script.Core.Animation.withAnimation),
		}),

		Bar = strict({
			ThreeSection = require(script.Core.Bar.ThreeSectionBar),
		}),

		ImageSet = strict({
			Button = require(script.Core.ImageSet.ImageSetComponent).Button,
			Label = require(script.Core.ImageSet.ImageSetComponent).Label,
			Validator = strict({
				validateImage = require(script.Core.ImageSet.Validator.validateImage),
			}),
		}),

		Control = strict({
			Enum = strict({
				ControlState = require(script.Core.Control.Enum.ControlState),
				SelectionMode = require(script.Core.Control.Enum.SelectionMode),
			}),
			Interactable = require(script.Core.Control.Interactable),
			InteractableList = require(script.Core.Control.InteractableList),
		}),

		Style = strict({
			Validator = strict({
				validateFontInfo = require(script.Core.Style.Validator.validateFontInfo),
				validateColorInfo = require(script.Core.Style.Validator.validateColorInfo),
			}),
			Provider = require(script.Core.Style.StyleProvider),
			withStyle = require(script.Core.Style.withStyle),
		}),

		Text = strict({
			ExpandableText = strict({
				GetCanExpand = require(script.Core.Text.ExpandableText.ExpandableTextUtils).getCanExpand
			}),
		}),

		InfiniteScroller = strict(require(Packages.InfiniteScroller)),
	})

	UIBlox.App = strict({
		Context = strict({
			ContentProvider = require(script.App.Context.ContentProvider)
		}),

		ImageSet = strict({
			Images = require(script.App.ImageSet.Images),
			getIconSize = require(script.App.ImageSet.getIconSize),
			getIconSizeUDim2 = require(script.App.ImageSet.getIconSizeUDim2),
			scaleSliceToResolution = require(script.App.ImageSet.scaleSliceToResolution),
			Enum = strict({
				IconSize = require(script.App.ImageSet.Enum.IconSize)
			}),
		}),

		Accordion = strict({
			AccordionView = require(script.App.Accordion.AccordionView),
		}),

		Bar = strict({
			HeaderBar = configs.useHeaderBarV2 and require(script.App.Bar.HeaderBarV2) or require(script.App.Bar.HeaderBar),
			RootHeaderBar = configs.useHeaderBarV2 == false and require(script.App.Bar.RootHeaderBar) or nil,
			FullscreenTitleBar = require(script.App.Bar.FullscreenTitleBar),
		}),

		Button = strict({
			Enum = strict({
				ButtonType = require(script.App.Button.Enum.ButtonType),
			}),
			PrimaryContextualButton = require(script.App.Button.PrimaryContextualButton),
			PrimarySystemButton = require(script.App.Button.PrimarySystemButton),
			SecondaryButton = require(script.App.Button.SecondaryButton),
			AlertButton = require(script.App.Button.AlertButton),
			ButtonStack = require(script.App.Button.ButtonStack),
			TextButton = require(script.App.Button.TextButton),
			LinkButton = require(script.App.Button.LinkButton),
			IconButton = require(script.App.Button.IconButton),
			ActionBar = require(script.App.Button.ActionBar)
		}),

		Cell = strict({
			Small = strict({
				SelectionGroup = strict({
					SmallRadioButtonGroup = require(script.App.Cell.Small.SelectionGroup.SmallRadioButtonGroup),
				})
			})
		}),

		Text = strict({
			ExpandableTextArea = require(script.App.Text.ExpandableTextArea.ExpandableTextArea),
			StyledTextLabel = require(script.App.Text.StyledTextLabel),
		}),

		Loading = strict({
			Enum = strict({
				RetrievalStatus = require(script.App.Loading.Enum.RetrievalStatus),
				LoadingState = require(script.App.Loading.Enum.LoadingState),
				RenderOnFailedStyle = require(script.App.Loading.Enum.RenderOnFailedStyle),
				ReloadingStyle = require(script.App.Loading.Enum.ReloadingStyle),
			}),
			LoadableImage = require(script.App.Loading.LoadableImage),
			ShimmerPanel = require(script.App.Loading.ShimmerPanel),
			LoadingSpinner = require(script.App.Loading.LoadingSpinner),
		}),

		InputButton = strict({
			RadioButtonList = require(script.App.InputButton.RadioButtonList),
			CheckboxList = require(script.App.InputButton.CheckboxList),
			Checkbox = require(script.App.InputButton.Checkbox),
			Toggle = require(script.App.InputButton.Toggle),
		}),

		Container = strict({
			Carousel = strict({
				FreeFlowCarousel = require(script.App.Container.Carousel.FreeFlowCarousel),
				--[[
					TODO: Remove ScrollButton when we switch the new carouels without infinite scroller
					We need this temporarily for the old carousels only, see https://jira.rbx.com/browse/APPFDN-230
					Only to be used in ScrollingAppCarousel
				]]
				ScrollButton = require(script.App.Container.Carousel.ScrollButton),
			}),
			VerticalScrollView = require(script.App.Container.VerticalScrollView),
			getPageMargin = require(script.App.Container.getPageMargin),
			LoadingStateContainer = require(script.App.Container.LoadingStateContainer),
			HorizontalPageMargin = require(script.App.Container.HorizontalPageMargin),
		}),

		Slider = strict({
			ContextualSlider = require(script.App.Slider.ContextualSlider),
			SystemSlider = require(script.App.Slider.SystemSlider),
			TwoKnobSystemSlider = require(script.App.Slider.TwoKnobSystemSlider),
			TwoKnobContextualSlider = require(script.App.Slider.TwoKnobContextualSlider),
		}),

		Grid = strict({
			GridView = require(script.App.Grid.GridView),
			GridMetrics = require(script.App.Grid.GridMetrics),
			DefaultMetricsGridView = require(script.App.Grid.DefaultMetricsGridView),
			ScrollingGridView = require(script.App.Grid.ScrollingGridView),
		}),

		Pill = strict({
			SmallPill = require(script.App.Pill.SmallPill),
			LargePill = require(script.App.Pill.LargePill),
		}),

		Tile = strict({
			Enum = strict({
				ItemTileEnums = require(script.App.Tile.Enum.ItemTileEnums),
			}),
			SaveTile = require(script.App.Tile.SaveTile.SaveTile),
			ItemTile = require(script.App.Tile.ItemTile.ItemTile),
			ItemTileFooter = require(script.App.Tile.ItemTile.ItemTileFooter),
			MenuTile = require(script.App.Tile.MenuTile.MenuTile),
			Experimental = strict({
				-- BaseTile should not be officially exposed.
				-- Currently it's used for experimental LuaApp PlayerTile.
				-- Remove the exposure of BaseTile when the PlayerTile design is firm.
				BaseTile = require(script.App.Tile.BaseTile.Tile),
			}),
		}),

		Dialog = strict({
			Modal = strict({
				FullPageModal = require(script.App.Dialog.Modal.FullPageModal),
				PartialPageModal = require(script.App.Dialog.Modal.PartialPageModal),
				EducationalModal = require(script.App.Dialog.Modal.EducationalModal),
			}),
			Alert = strict({
				InformativeAlert = require(script.App.Dialog.Alert.InformativeAlert),
				InteractiveAlert = require(script.App.Dialog.Alert.InteractiveAlert),
				LoadingAlert = require(script.App.Dialog.Alert.LoadingAlert),
			}),
			Enum = strict({
				AlertType = require(script.App.Dialog.Alert.Enum.AlertType),
				TooltipOrientation = require(script.App.Dialog.Tooltip.Enum.TooltipOrientation),
			}),
			Toast = require(script.App.Dialog.Toast.SlideFromTopToast),
			Tooltip = require(script.App.Dialog.Tooltip.Tooltip),
		}),

		Constant = strict({
			-- DEPRECATED: use App.ImageSet.getIconSize to get the size
			IconSize = require(script.App.Constant.IconSize),
		}),

		Style = strict({
			Validator = strict({
				validateFont = require(script.App.Style.Validator.validateFont),
				validateTheme = require(script.App.Style.Validator.validateTheme),
				validateStyle = require(script.App.Style.Validator.validateStyle),
			}),
			AppStyleProvider = require(script.App.Style.AppStyleProvider),
			Colors = require(script.App.Style.Colors),
			Constants = require(script.App.Style.Constants),
		}),

		Indicator = strict({
			Badge = require(script.App.Indicator.Badge),
			EmptyState = require(script.App.Indicator.EmptyState),
		}),

		Menu = strict({
			BaseMenu = require(script.App.Menu.BaseMenu),
			OverlayBaseMenu = require(script.App.Menu.OverlayBaseMenu),

			ContextualMenu = require(script.App.Menu.ContextualMenu),
			OverlayContextualMenu = require(script.App.Menu.OverlayContextualMenu),

			MenuDirection = require(script.App.Menu.MenuDirection),

			DropdownMenu = require(script.App.Menu.DropdownMenu),

		}),

		Control = strict({
			Knob = require(script.App.Control.Knob.Knob),
			SegmentedControl = require(script.App.Control.SegmentedControl),
			RobuxBalance = require(script.App.Control.RobuxBalance),
		}),

		Navigation = strict({
			Enum = strict({
				Placement = require(script.App.Navigation.Enum.Placement),
			}),
			SystemBar = require(script.App.Navigation.SystemBar),
		}),

		SelectionImage = strict({
			SelectionCursorProvider = require(script.App.SelectionImage.SelectionCursorProvider),
			CursorKind = require(script.App.SelectionImage.CursorKind),
			withSelectionCursorProvider = require(script.App.SelectionImage.withSelectionCursorProvider),
		}),

	})

	-- DEPRECATED SECTION

	-- DEPRECATED: Use Core.Style instead
	UIBlox.Style = {
		-- These redirect to Core, which ultimately redirect back to original.
		-- If we do it this, switching to `UIBlox.Core.Style` is a separate step
		-- from deprecating `UIBlox.Style`, and the latter is just an API naming
		-- change with no other consequences
		Provider = UIBlox.Core.Style.Provider,
		withStyle = UIBlox.Core.Style.withStyle,
		Validator = {
			validateStyle = require(script.Style.Validator.validateStyle),
			validateFont = require(script.Style.Validator.validateFont),
			validateFontInfo = require(script.Style.Validator.validateFontInfo),
			validateTheme = require(script.Style.Validator.validateTheme),
			validateColorInfo = require(script.Style.Validator.validateColorInfo),
		},
	}

	-- DEPRECATED: This is kept for compatibility. Use App.Accordion.AccordionView instead.
	UIBlox.AccordionView = require(script.App.Accordion.AccordionView)

	-- DEPRECATED: This is kept for compatibility. This should not be used because it is an old design.
	-- Use ContextualMenu instead
	UIBlox.ModalBottomSheet = require(script.ModalBottomSheet.ModalBottomSheet)

	-- DEPRECATED: This is kept for compatibility.
	UIBlox.Utility = {
		ExternalEventConnection = require(script.Utility.ExternalEventConnection),
		--Use Core.Animation.SpringAnimatedItem instead
		SpringAnimatedItem = require(script.Utility.SpringAnimatedItem),
	}

	-- DEPRECATED: use Core.Loading instead.
	UIBlox.Loading = {
		LoadableImage = require(script.App.Loading.LoadableImage),
		ShimmerPanel = require(script.App.Loading.ShimmerPanel),
	}

	-- DEPRECATED: use App.Tile instead.
	UIBlox.Tile = {
		SaveTile = require(script.App.Tile.SaveTile.SaveTile),
		ItemTile = require(script.App.Tile.ItemTile.ItemTile),
		ItemTileEnums = require(script.App.Tile.Enum.ItemTileEnums),
	}

	-- END DEPRECATED SECTION

	return UIBlox
end

return makeConfigurable(initializeLibrary, "UIBlox", UIBloxDefaultConfig)
