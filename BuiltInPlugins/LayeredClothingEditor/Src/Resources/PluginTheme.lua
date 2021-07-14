local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Packages.Cryo)

local Framework = require(Plugin.Packages.Framework)

local Util = Framework.Util
local StyleModifier = Util.StyleModifier

local getRawComponentStyle = Framework.Style.getRawComponentStyle

local UILibrary = require(Plugin.Packages.UILibrary)
local UI = Framework.UI
local Spritesheet = UILibrary.Util.Spritesheet

local FrameworkStyle = Framework.Style
local StudioTheme = FrameworkStyle.Themes.StudioTheme
local StyleKey = FrameworkStyle.StyleKey
local ui = FrameworkStyle.ComponentSymbols

local DarkTheme = FrameworkStyle.Themes.DarkTheme
local LightTheme = FrameworkStyle.Themes.LightTheme

local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)

local darkThemeOverride = Cryo.Dictionary.join(DarkTheme, {
	[StyleKey.PlayImage] = "rbxasset://textures/LayeredClothingEditor/Icon_Play_Light.png",
	[StyleKey.AddMoreImage] = "rbxasset://textures/LayeredClothingEditor/Icon_AddMore_Light.png",
	[StyleKey.MoreActionsImage] = "rbxasset://textures/LayeredClothingEditor/Icon_MoreAction_Light.png",
	[StyleKey.AddMoreBigImage] = "rbxasset://textures/LayeredClothingEditor/AddMore_Big_50X50_Light.png",
})

local lightThemeOverride = Cryo.Dictionary.join(LightTheme, {
	[StyleKey.PlayImage] = "rbxasset://textures/LayeredClothingEditor/Icon_Play_Dark.png",
	[StyleKey.AddMoreImage] = "rbxasset://textures/LayeredClothingEditor/Icon_AddMore_Dark.png",
	[StyleKey.MoreActionsImage] ="rbxasset://textures/LayeredClothingEditor/Icon_MoreAction_Dark.png",
	[StyleKey.AddMoreBigImage] = "rbxasset://textures/LayeredClothingEditor/AddMore_Big_50X50_Dark.png",
})

local function mockStyleKeyImages()
	StyleKey.PlayImage = "rbxasset://textures/LayeredClothingEditor/Icon_Play_Dark.png"
	StyleKey.AddMoreImage = "rbxasset://textures/LayeredClothingEditor/Icon_AddMore_Dark.png"
	StyleKey.MoreActionsImage ="rbxasset://textures/LayeredClothingEditor/Icon_MoreAction_Dark.png"
	StyleKey.AddMoreBigImage = "rbxasset://textures/LayeredClothingEditor/AddMore_Big_50X50_Dark.png"
end

local function createValuesInternal(mock)
	if mock then
		mockStyleKeyImages()
	end

	local arrowSpritesheet = Spritesheet("rbxasset://textures/StudioSharedUI/arrowSpritesheet.png", {
		SpriteSize = 12,
		NumSprites = 4,
	})
	local downArrowProps = arrowSpritesheet[3]

	local devFrameworkRoundTextInput = getRawComponentStyle("TextInput")
	local TextInput = Cryo.Dictionary.join(devFrameworkRoundTextInput, {
		PlaceholderTextColor = StyleKey.DimmedText,
		TextColor = StyleKey.MainText,
		["&RoundedBorder"] = {
			Padding = {
				Left = 10,
				Top = 5,
				Right = 10,
				Bottom = 5
			},
			BackgroundStyle = {
				Color = StyleKey.RibbonTab,
				BorderColor = StyleKey.RibbonTab,
				Transparency = 0,
				BorderTransparency = 0,
				BackgroundImage = "rbxasset://textures/StudioToolbox/RoundedBackground.png",
				BorderImage = "rbxasset://textures/StudioToolbox/RoundedBorder.png",
				SliceCenter = Rect.new(3, 3, 13, 13),
			},
		}
	})

	local DeformerDropdownMenu = Cryo.Dictionary.join(downArrowProps, {
		Size = UDim2.new(0, 10, 0, 10),
		Color = StyleKey.MainText,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Padding = 96,
		DropdownFramePadding = 12,
		ArrowSize = 24,
		DropdownFrameWidth = 216,
		Font = Enum.Font.SourceSans,
		TextSize = 18,
	})

	local FlowScreenLayout = {
		ButtonWidth = 64,
		ButtonHeight = 24,
		HeaderHeight = 64,
	}

	local EditorScreen = {
		EditHeight = 350,
		EditAndPreviewHeight = 175,
		PreviewHeight = 350,
	}

	local SelectFrame = {
		TextBoxHeight = 24,
		LabelWidth = 64,
	}

	local EditorFrame = {
		Height = 140,
		EditingModeHeight = 36,
		CageRowTextLabelSize = 0.3,
	}

	local LatticeToolSettings = {
		UIPadding = 24,
		Height = 24,
		ButtonWidth = 64,
		LayoutPadding = 6,
	}

	local SwizzleView = {
		TopBarColor = StyleKey.Button,
		TopBarTextColor = StyleKey.TitlebarText,
		TextSize = 18,
		TopBarHeight = 32,
		TopBarPadding = 12,
		Arrows = {
			Collapsed = {
				Image = "rbxasset://textures/StudioToolbox/ArrowCollapsed.png",
				Size = UDim2.new(0, 9, 0, 7),
			},
			Expanded = {
				Image = "rbxasset://textures/StudioToolbox/ArrowExpanded.png",
				Size = UDim2.new(0, 7, 0, 9),
			}
		},
		ImageColor = StyleKey.MainText,
	}

	local CheckboxSetting = {
		BoxSize = UDim2.new(0, 20, 0, 20),
		FramePadding = 96,
	}

	local Point = {
		DefaultPointSize = 0.015,
		DefaultColor = Color3.new(0, 1, 1),
		HoveredColor = Color3.new(1, 1, 0),
		SelectedColor = Color3.new(1, 1, 0),
		SelectedColorNoWeight = Color3.new(1, 0, 0),
	}

	local PointTool = {
		DefaultPointSize = 0.015,
	}

	local ControlPoint = {
		Transparency = 0.7,
		PointSize = 0.1,
		DefaultColor = Color3.new(0, 0, 1),
		HoveredColor = Color3.new(1, 1, 0),
		SelectedColor = Color3.new(1, 0, 0),
	}

	local Vector3Entry = {
		PlaceholderTextColor = StyleKey.DimmedText,
		ValueTextBoxPadding = 12,
		ValueTextBoxWidth = 64,
		FramePadding = 96,
	}

	local SwitchButton = {
		BackgroundColor = StyleKey.MainBackground,
		TextColor = StyleKey.TitlebarText,
		BorderColor = StyleKey.Border,
		BorderSelectedColor = StyleKey.DialogMainButton,
		DisabledTextColor = StyleKey.DimmedText,
		TextSize = 15,
	}

	local EditTransparencyView = {
		TitleHeight = 32,
	}

	local AnimPlaybackSlider = {
		PlayImage = StyleKey.PlayImage,
		PauseImage = "rbxasset://textures/LayeredClothingEditor/Icon_Pause.png",
		PlayButtonWidth = 20,
		PlayTimeLabelWidth = 60,
		Padding = 24,
	}

	local InstanceSelector = {
		HoverLineThickness = 0.02,
	}

	local SliderSetting = {
		PercentageLabelWidth = 10,
		ValueTextBoxPadding = 5,
		SliderContainerPadding = 24,
		DefaultSnap = 1,
		LabelWidth = 80,
		InputWidth = 60,
		InputHeight = 22,
		TextInputOverride = Cryo.Dictionary.join(devFrameworkRoundTextInput, {
			Padding = 6,
			[StyleModifier.Disabled] = {
				TextColor = StyleKey.DimmedText,
			},
		}),
	}

	local AddItemFromExplorerButton = {
		AddFromExploreButtonFrameHeight = 25,
		AddFromExploreButtonImage = StyleKey.AddMoreImage,
		AddFromExploreButtonSize = UDim2.new(0, 20, 0, 20),
	}

	local EditingModeFrame = {
		CageRowTextLabelSize = 0.3,
	}

	local SelectItemFrame = {
		AddFromExploreButtonFrameHeight = 25,
	}

	local SelectItemList = {
		SelectItemListScrollingFrameStyle = {
			BackgroundColor3 = StyleKey.CategoryItem,
			ScrollBarThickness = 7,
			BorderSizePixel = 0,
			AutoSizeCanvas = true,
			AutoSizeLayoutElement = "UIListLayout",
			ScrollingDirection = Enum.ScrollingDirection.Y,
		},
	}

	local SelectItemListRow = {
		MoreButtonSize = 20,
		SelectableRowStyle = {
			Background = UI.Decoration.Box,
			BackgroundStyle = {
				BorderSize = 0,
				Transparency = 1,
			},
			[StyleModifier.Hover] = {
				BackgroundStyle = {
					Color = StyleKey.ButtonHover,
					Transparency = 0,
				},
			},
			[StyleModifier.Selected] = {
				BackgroundStyle = {
					Color = StyleKey.DialogMainButtonSelected,
					Transparency = 0,
				},
			}
		},
	}

	local SelectItemMoreButton = {
		MoreButtonImage = StyleKey.MoreActionsImage,
		MoreButtonSize = 20,
	}

	local ControlsPanelBlocker = {
		TextSize = 25,
		TextColor = Color3.fromRGB(255, 255, 255),
		BackgroundColor = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.2,
	}

	local Tile = {
		TileSize = UDim2.new(0, 140, 0, 160),
		TileInnerBorder = Vector2.new(10, 10),
		ImageFrameSize = UDim2.new(0, 120, 0, 118),
		ImageSize = UDim2.new(0, 100, 0, 98),
		TextLabelSize = UDim2.new(0, 120, 0, 22),

		ButtonBackgroundColor = StyleKey.ButtonPressed,
		TextSize = 18,
		ImageBackgroundColor = StyleKey.CategoryItem,
	}

	local EditingModeRadioButtonList = {
		Padding = 8,
	}

	local TabsRibbon = {
		Height = 40,
		ButtonHeightWidth = 60,
	}

	local PreviewTabsRibbon = {
		Icons = {
			[PreviewConstants.TABS_KEYS.Avatars] = "rbxasset://textures/LayeredClothingEditor/Icon_Preview_Avatars.png",
			[PreviewConstants.TABS_KEYS.Clothing] = "rbxasset://textures/LayeredClothingEditor/Icon_Preview_Clothing.png",
			[PreviewConstants.TABS_KEYS.Animations] = "rbxasset://textures/LayeredClothingEditor/Icon_Preview_Animation.png",
		},
	}

	local Grid = {
		TileSize = UDim2.new(0, 140, 0, 160),
		TileInnerBorder = Vector2.new(10, 10),
		ImageFrameSize = UDim2.new(0, 120, 0, 118),
		ImageSize = UDim2.new(0, 100, 0, 98),
		TextLabelSize = UDim2.new(0, 120, 0, 22),

		ButtonBackgroundColor = StyleKey.ButtonPressed,
		TextSize = 18,
		DefaultTileImages = {
			[PreviewConstants.TABS_KEYS.Avatars] = "rbxasset://textures/LayeredClothingEditor/Default_Preview_Avatars.png",
			[PreviewConstants.TABS_KEYS.Clothing] = "rbxasset://textures/LayeredClothingEditor/Default_Preview_Clothing.png",
			[PreviewConstants.TABS_KEYS.Animations] = "rbxasset://textures/LayeredClothingEditor/Default_Preview_Animation.png",
		},
		AddNewImage = StyleKey.AddMoreBigImage,
		SmallImageSize = UDim2.new(0, 46, 0, 42),
		ImageBackgroundColor = StyleKey.CategoryItem,
	}

	local Lattice = {
		LinkColor = Color3.new(0, 0, 0),
	}

	local Wireframe = {
		WireColorInner = Color3.fromRGB(68, 103, 128),
		WireColorOuter = Color3.fromRGB(140, 65, 168),
	}

	local ResetSettings = {
		ButtonHeight = 36
	}

	local MeshPartTool = {
		Transparency = 0.8,
		InBoundsColor = Color3.new(0, 0, 1),
		OutBoundsColor = Color3.new(1, 0, 0),
	}

	local rootTheme = {
		BackgroundColor = StyleKey.MainBackground,
		ButtonColor = StyleKey.Button,
		RibbonTab = StyleKey.RibbonTab,
		ProgressBarColor = StyleKey.DialogMainButtonSelected,
		ScrollBarColor = StyleKey.ScrollBar,
		HoverColor = StyleKey.ButtonHover,
		BorderColor = StyleKey.Border,
		SubTextColor = StyleKey.SubText,
		InfoTextColor = StyleKey.DimmedText,
		TitleTextColor = StyleKey.TitlebarText,
		TextColor = StyleKey.MainText,
		TextDisabledColor = Color3.fromRGB(148, 148, 148),
		ErrorColor = StyleKey.ErrorText,
		LinkColor = StyleKey.LinkText,
		Green = Color3.fromRGB(64, 166, 81),
		White = Color3.fromRGB(255, 255, 255),
		DisabledColor = StyleKey.MainTextDisabled,
		ScrollbarTransparency = 0.7,
		ScrollbarSize = 7,
		TextSize = 18,
		RowHeight = 32,
		Font = Enum.Font.SourceSans,
		FontBold = Enum.Font.SourceSansSemibold,
		PopupMessageSize = Vector2.new(200, 100),
		MainPadding = 20,
		HeaderPadding = 8,
		SliderHeight = 32,
		ScrollBarThickness = 8,
	}

	local componentThemes = {
		FlowScreenLayout = FlowScreenLayout,
		EditorScreen = EditorScreen,
		EditorFrame = EditorFrame,
		DeformerDropdownMenu = DeformerDropdownMenu,
		LatticeToolSettings = LatticeToolSettings,
		SwizzleView = SwizzleView,
		Vector3Entry = Vector3Entry,
		SwitchButton = SwitchButton,
		AddItemFromExplorerButton = AddItemFromExplorerButton,
		EditingModeFrame = EditingModeFrame,
		EditingModeRadioButtonList = EditingModeRadioButtonList,
		SelectItemFrame = SelectItemFrame,
		SelectItemList = SelectItemList,
		SelectItemListRow = SelectItemListRow,
		SelectItemMoreButton = SelectItemMoreButton,
		Grid = Grid,
		ControlsPanelBlocker = ControlsPanelBlocker,
		EditTransparencyView = EditTransparencyView,
		AnimPlaybackSlider = AnimPlaybackSlider,
		SliderSetting = SliderSetting,
		CheckboxSetting = CheckboxSetting,
		Tile = Tile,
		TabsRibbon = TabsRibbon,
		PreviewTabsRibbon = PreviewTabsRibbon,
		SelectFrame = SelectFrame,
		PointTool = PointTool,
		Point = Point,
		ControlPoint = ControlPoint,
		Lattice = Lattice,
		Wireframe = Wireframe,
		ResetSettings = ResetSettings,
		TextInput = TextInput,
		InstanceSelector = InstanceSelector,
		MeshPartTool = MeshPartTool,
	}

	return rootTheme, componentThemes
end

local function createValues(mock)
	local rootTheme, componentThemes = createValuesInternal(mock)
	local componentThemeStyles = {}
	for component, componentTheme in pairs(componentThemes) do
		local componentUI = ui:add(component)
		componentThemeStyles[componentUI] = componentTheme
	end
	return Cryo.Dictionary.join(rootTheme, componentThemeStyles)
end

local PluginTheme = {}

function PluginTheme.makePluginTheme()
	local styleRoot = StudioTheme.new(darkThemeOverride, lightThemeOverride)
	styleRoot:extend(createValues())
	return styleRoot
end

function PluginTheme.mock()
	local styleRoot = StudioTheme.mock(darkThemeOverride, lightThemeOverride)
	styleRoot:extend(createValues(true))
	return styleRoot
end

function PluginTheme.getMockTheme(childName)
	return PluginTheme.mock()
end

return PluginTheme