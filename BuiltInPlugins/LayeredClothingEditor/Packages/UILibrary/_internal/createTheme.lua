--[[
	Transforms values from an app theme into a theme usable by the UILibrary.

	Parameters:
		table style:
			Specifies default style values which will be used to construct the theme.
			These include the basic palette colors (backgroundColor, textColor, etc),
			as well as other top-level fonts and sizes. Refer to defaultStyle for
			a list of style values that can be overridden.

		table overrides (optional):
			After the theme is created, overrides can be set for specific elements.

			For example, an overrides table of:
			{
				checkBox.backgroundColor = Color3.new(1, 1, 1),
			}

			Would change the background color of only the Checkbox component.
]]

local Style = require(script.Parent.StyleDefaults)
local replaceDefaults = require(script.Parent.deepJoin)

return function(style, overrides)
	style = style or {}
	overrides = overrides or {}

	style = replaceDefaults(Style.Defaults, style)
	assert(Style.isValid(style), "Provided style table could not be validated.")

	-- Theme entries for UILibrary components are defined below
	local checkBox = {
		font = style.font,

		--TODO: Move texture to StudioSharedUI
		backgroundImage = "rbxasset://textures/GameSettings/UncheckedBox.png",
		selectedImage = "rbxasset://textures/GameSettings/CheckedBoxLight.png",

		backgroundColor = style.backgroundColor,
		titleColor = style.textColor,
	}

	local roundFrame = {
		--TODO: Move texture to StudioSharedUI
		backgroundImage = "rbxasset://textures/StudioToolbox/RoundedBackground.png",
		borderImage = "rbxasset://textures/StudioToolbox/RoundedBorder.png",
		slice = Rect.new(3, 3, 13, 13),
	}

	local dropShadow = {
		--TODO: Move texture to StudioSharedUI
		image = "rbxasset://textures/StudioUIEditor/resizeHandleDropShadow.png",
	}

	local tooltip = {
		font = style.font,
		textSize = 12,

		backgroundColor = style.itemColor,
		borderColor = style.borderColor,
		textColor = style.textColor,
		shadowColor = style.shadowColor,
		shadowTransparency = style.shadowTransparency,
	}

	local keyframe = {
		Default = {
			backgroundColor = style.itemColor,
			borderColor = style.borderColor,

			selected = {
				backgroundColor = style.selectionColor,
				borderColor = style.selectionBorderColor,
			},
		},

		Primary = {
			backgroundColor = style.primaryItemColor,
			borderColor = style.primaryBorderColor,

			selected = {
				backgroundColor = style.primaryHoveredItemColor,
				borderColor = style.selectionBorderColor,
			},
		},
	}

	local scrubber = {
		backgroundColor = style.selectionColor,
		image = "",
	}

	local scrollingFrame = {
		--TODO: Move texture to StudioSharedUI
		topImage = "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
		midImage = "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
		bottomImage = "rbxasset://textures/StudioToolbox/ScrollBarBottom.png",

		backgroundColor = style.backgroundColor,
		scrollbarColor = style.borderColor,
	}

	local radioButton = {
		radioButtonBackground = "rbxasset://textures/GameSettings/RadioButton.png",
		radioButtonColor = style.separationLineColor,
		radioButtonSelected = "rbxasset://textures/ui/LuaApp/icons/ic-blue-dot.png",
		textSize = 18,
		buttonHeight = 20,
		font = style.font,
		textColor = style.textColor,
		contentPadding = 16,
		buttonPadding = 6,
	}

	local dropdownMenu = {
		borderColor = style.borderColor,
		--TODO: Move texture to StudioSharedUI
		borderImage = "rbxasset://textures/StudioToolbox/RoundedBorder.png",
	}

	local styledDropdown = {
		font = style.font,

		backgroundColor = style.backgroundColor,
		borderColor = style.borderColor,
		textColor = style.textColor,

		--TODO: Move texture to StudioSharedUI
		arrowImage = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png",

		hovered = {
			backgroundColor = style.hoveredItemColor,
			textColor = style.hoveredTextColor,
		},

		selected = {
			backgroundColor = style.selectionColor,
			borderColor = style.selectionBorderColor,
			textColor = style.selectedTextColor,
		},
	}

	local detailedDropdown = {
		font = style.font,

		backgroundColor = style.backgroundColor,
		disabled = style.disabledColor,
		disabledText = style.dimmerTextColor,
		borderColor = style.borderColor,
		displayText = style.textColor,
		descriptionText = style.subTextColor,

		--TODO: Move texture to StudioSharedUI
		arrowImage = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png",

		hovered = {
			backgroundColor = style.hoveredItemColor,
			displayText = style.hoveredTextColor,
		},

		selected = {
			backgroundColor = style.selectionColor,
			disabled = style.disabledColor,
			borderColor = style.selectionBorderColor,
			displayText = style.selectedTextColor,
		},
	}

	local titledFrame = {
		font = style.font,
		text = style.subTextColor,
	}

	local textBox = {
		font = style.font,
		background = style.backgroundColor,
		disabled = style.disabledColor,
		borderDefault = style.borderColor,
		borderHover = style.hoverColor,
		tooltip = style.dimmerTextColor,
		text = style.textColor,
		error = style.errorColor,
	}

	local textButton = {
		font = style.font,
	}

	local textEntry = {
		textTransparency = {
			enabled = 0,
			disabled = 0.5
		}
	}

	local separator = {
		lineColor = style.borderColor,
	}

	local treeView = {
		elementPadding = 4,
		margins = {
			left = 2,
			top = 2,
			right = 2,
			bottom = 2,
		},
		indentOffset = 8,
		scrollbar = replaceDefaults(scrollingFrame, {
			scrollbarThickness = 16,
			scrollbarPadding = 2,
			scrollbarImageColor = style.borderColor,
		}),
		defaultElementWidth = 140,
	}

	local dialog = {
		font = style.font,

		background = style.backgroundColor,
		textColor = style.textColor,
	}

	local bulletPoint = {
		font = style.font,

		text = style.textColor,
	}

	local button = {
		Default = {
			font = style.font,
			isRound = true,

			backgroundColor = style.itemColor,
			textColor = style.textColor,
			borderColor = style.borderColor,

			hovered = {
				backgroundColor = style.hoveredItemColor,
				textColor = style.hoveredTextColor,
				borderColor = style.borderColor,
			},
		},

		Primary = {
			font = style.font,
			isRound = true,

			backgroundColor = style.primaryItemColor,
			textColor = style.primaryTextColor,
			borderColor = style.primaryBorderColor,

			hovered = {
				backgroundColor = style.primaryHoveredItemColor,
				textColor = style.primaryHoveredTextColor,
				borderColor = style.primaryHoveredBorderColor,
			},
		},
	}

	local loadingBar = {
		font = style.font,
		fontSize = 16,
		text = style.textColor,
		bar = {
			foregroundColor = style.dimmerTextColor,
			backgroundColor = style.backgroundColor,
		},
	}

	local loadingIndicator = {
		baseColor = style.hoveredItemColor,
		endColor = style.dimmerTextColor,
	}

	local toggleButton = {
		defaultWidth = 20,
		defaultHeight = 20,

		onImage = "rbxasset://textures/RoactStudioWidgets/toggle_on_light.png",
		offImage = "rbxasset://textures/RoactStudioWidgets/toggle_off_light.png",
		disabledImage = "rbxasset://textures/RoactStudioWidgets/toggle_disable_light.png",
	}

	local hyperlink = {
		textSize = 22,
		textColor = style.hyperlinkTextColor,
		font = style.font,
	}

	local partialHyperlink = {
		textColor = style.textColor,
		font = style.font,
		textSize = 22,
	}

	local assetPreview = {
		font = style.font,
		textSize = 14,
		textSizeMedium = 16,
		textSizeLarge = 18,
		textSizeTitle= 22,
		fontBold = style.font,
		background = style.backgroundColor,

		padding = 12,

		assetNameColor = style.textColor,
		descriptionTextColor = style.textColor,

		actionBar = {
			background = style.backgroundColor,

			button = {
				backgroundColor = style.primaryItemColor,
				backgroundDisabledColor = style.disabledColor,
				backgroundHoveredColor = style.primaryHoveredItemColor
			},

			showMore = {
				backgroundColor = style.backgroundColor,
				borderColor = style.borderColor
			},

			text = {
				color = style.textColor,
				colorDisabled = style.disabledColor,
			},

			padding = 12,
			centerPadding = 10,

			robuxSize = UDim2.fromOffset(16,16),

			images = {
				showMore = "rbxasset://textures/StudioToolbox/AssetPreview/more.png",
				robuxSmall = "rbxasset://textures/ui/common/robux_small.png",
				colorWhite = Color3.fromRGB(255, 255, 255),
			}
		},

		description = {
			height = 28,

			searchBarIconSize = 14,
			padding = 8,

			backgroundColor = style.backgroundColor,
			leftTextColor = style.textColor,
			rightTextColor = style.textColor,
			lineColor = style.borderColor,

			images = {
				searchIcon = "rbxasset://textures/StudioToolbox/Search.png",
			},
		},

		images = {
			deleteButton = "rbxasset://textures/StudioToolbox/DeleteButton.png",
			scrollbarTopImage = "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
			scrollbarMiddleImage = "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
			scrollbarBottomImage = "rbxasset://textures/StudioToolbox/ScrollBarBottom.png",
			thumbUpSmall = "rbxasset://textures/StudioToolbox/AssetPreview/rating_small.png",
		},

		favorites = {
			contentColor = Color3.fromRGB(246, 183, 2),
			favorited = "rbxasset://textures/StudioToolbox/AssetPreview/star_filled.png",
			unfavorited = "rbxasset://textures/StudioToolbox/AssetPreview/star_stroke.png"
		},

		imagePreview = {
			background = style.backgroundColor,
			textColor = style.textColor,
		},

		modelPreview = {
			background = style.backgroundColor,
		},

		thumbnailIconPreview = {
			background = style.backgroundColor,
			textColor = style.textColor,

			textLabelPadding  = 20,
			iconSize = 16,
			defaultTextLabelHeight = 20,
		},

		treeViewButton = {
			buttonSize = 28,
			backgroundTrans = 0.25,
			backgroundColor = style.background,
			backgroundDisabledColor = style.disabledColor,
			hierarchy = "rbxasset://textures/StudioToolbox/AssetPreview/hierarchy.png"
		},

		audioPreview = {
			backgroundColor = style.backgroundColor,
			textColor = style.textColor,
			playButton = "rbxasset://textures/StudioToolbox/AssetPreview/play_button.png",
			pauseButton = "rbxasset://textures/StudioToolbox/AssetPreview/pause_button.png",
			buttonBackgroundColor = style.background,
			buttonDisabledBackgroundColor = style.disabledColor,
			buttonDisabledBackgroundTransparency = 0.5,
			buttonColor = style.textColor,
			audioPlay_BG = "rbxasset://textures/StudioToolbox/AssetPreview/audioPlay_BG.png",
			audioPlay_BG_Color = Color3.fromRGB(204, 204, 204),
			progressBar = Color3.fromRGB(0, 162, 255),
			progressBar_BG_Color = style.background,
			progressKnob = "rbxasset://textures/DeveloperFramework/slider_knob.png",
			progressKnobColor = style.background,
			font = style.font,
			fontSize = 16,
		},

		videoPreview = {
			backgroundColor = style.backgroundColor,
			videoBackgroundColor = style.backgroundColor,
			playButton = "rbxasset://textures/StudioToolbox/AssetPreview/play_button.png",
			pauseButton = "rbxasset://textures/StudioToolbox/AssetPreview/pause_button.png",
			pauseOverlayColor =Color3.fromRGB(0, 0, 0),
			pauseOverlayTransparency = 0.5,
		},

		vote = {
			backgroundTrans = 0.9,
			background = style.backgroundColor,
			borderColor = style.borderColor,
			textColor = style.textColor,
			subTextColor = style.subTextColor,

			button = {
				backgroundColor = style.itemColor,
				backgroundTrans = 0,
				disabledColor = Color3.fromRGB(10, 10, 10),
			},

			voteUp = {
				backgroundColor = Color3.fromRGB(0, 100, 0),
				borderColor = style.borderColor,
			},

			voteDown = {
				backgroundColor = Color3.fromRGB(100, 0, 0),
				borderColor = style.borderColor,
			},

			images = {
				voteDown = "rbxasset://textures/StudioToolbox/AssetPreview/vote_down.png",
				voteUp = "rbxasset://textures/StudioToolbox/AssetPreview/vote_up.png",
				thumbUp = "rbxasset://textures/StudioToolbox/AssetPreview/rating_large.png"
			}
		},
	}

	local searchBar = {
		backgroundColor = style.backgroundColor,

		text = {
			placeholder = {
				color = style.dimmerTextColor,
			},
			font = style.font,
			size = 16,
			color = style.textColor,
		},

		divideLine = {
			color = style.borderColor,
		},

		border = {
			hovered = {
				color = style.hoverColor,
			},
			selected = {
				color = style.selectionBorderColor,
			},
			color = style.borderColor,
		},

		buttons = {
			iconSize = 14,
			size = 28,
			inset = 2,
			clear = {
				color = Color3.fromRGB(184, 184, 184),
			},

			search = {
				hovered = {
					color = Color3.fromRGB(0, 162, 255),
				},
				color = Color3.fromRGB(184, 184, 184),
			},
		},

		images = {
			clear = {
				hovered = {
					image = "rbxasset://textures/StudioSharedUI/clear-hover.png",
				},
				image = "rbxasset://textures/StudioSharedUI/clear.png",
			},

			search = {
				image = "rbxasset://textures/StudioSharedUI/search.png",
			},
		},
	}

	local instanceTreeView = {
		font = style.font,
		textSize = 14,

		background = style.background,

		treeItemHeight = 16,
		treeViewIndent = 20,

		scrollbarPadding = 2,
		scrollbarThickness = 8,

		scrollbarTopImage = "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
		scrollbarMiddleImage = "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
		scrollBarBottomImage = "rbxasset://textures/StudioToolbox/ScrollBarBottom.png",

		arrowExpanded = "rbxasset://textures/StudioToolbox/ArrowExpanded.png",
		arrowCollapsed = "rbxasset://textures/StudioToolbox/ArrowCollapsed.png",

		elementPadding = 4,

		borderPadding = 15,

		tooltipShowDelay = 0.3,

		arrowColor = style.textColor,
		selectedText = style.selectedTextColor,
		textColor = style.textColor,
		selected = style.selectedTextColor,
		hover = style.hoverColor,
	}

	local styledTooltip = {
		backgroundColor = style.itemColor,
		shadowColor = style.shadowColor,
		shadowTransparency = style.shadowTransparency,
		shadowOffset = Vector2.new(1, 1),
	}

	return replaceDefaults({
		assetPreview = assetPreview,
		checkBox = checkBox,
		roundFrame = roundFrame,
		dropShadow = dropShadow,
		tooltip = tooltip,
		keyframe = keyframe,
		scrollingFrame = scrollingFrame,
		dropdownMenu = dropdownMenu,
		styledDropdown = styledDropdown,
		detailedDropdown = detailedDropdown,
		titledFrame = titledFrame,
		textBox = textBox,
		textButton = textButton,
		textEntry = textEntry,
		separator = separator,
		dialog = dialog,
		button = button,
		scrubber = scrubber,
		loadingBar = loadingBar,
		loadingIndicator = loadingIndicator,
		bulletPoint = bulletPoint,
		toggleButton = toggleButton,
		radioButton = radioButton,
		treeView = treeView,
		hyperlink = hyperlink,
		partialHyperlink = partialHyperlink,
		instanceTreeView = instanceTreeView,
		searchBar = searchBar,
		styledTooltip = styledTooltip,
	}, overrides)
end