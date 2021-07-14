local Framework = script.Parent.Parent.Parent
local StyleKey = require(Framework.Style.StyleKey)
local Colors = require(Framework.Style.Colors)

local FFlagDevFrameworkFixButtonStyles = game:GetFastFlag("DevFrameworkFixButtonStyles")
local FFlagDevFrameworkRefactorScrollbarColor = game:GetFastFlag("DevFrameworkRefactorScrollbarColor")

return {
	[StyleKey.Border] = Color3.fromRGB(182, 182, 182),
	[StyleKey.BrightText] = Colors.Black,
	[StyleKey.Button] = Colors.White,
	[StyleKey.ButtonText] = Colors.Black,
	[StyleKey.ButtonHover] = Color3.fromRGB(228, 238, 254),
	[StyleKey.ButtonDisabled] = Colors.White,
	[StyleKey.ButtonTextDisabled] = Color3.fromRGB(102, 102, 102),
	[StyleKey.ButtonPressed] = Color3.fromRGB(219, 219, 219),
	[StyleKey.ButtonSelected] = Color3.fromRGB(228, 238, 254),
	[StyleKey.ImageButtonBackground] = Color3.fromRGB(182, 182, 182),
	[StyleKey.ImageButtonHover] = Colors.lighter(Color3.fromRGB(182, 182, 182), 0.26),

	[StyleKey.Icon] = Color3.fromRGB(128, 128, 128),

	[StyleKey.CategoryItem] = Color3.fromRGB(233, 233, 233),

	[StyleKey.DialogButtonBorder] = Colors.Gray_Light,
	[StyleKey.DialogMainButton] = Colors.Blue,
	[StyleKey.DialogMainButtonDisabled] = Color3.fromRGB(153, 218, 255),
	[StyleKey.DialogMainButtonHover] = Colors.Blue_Light,
	[StyleKey.DialogMainButtonSelected] = Colors.Blue_Dark,
	[StyleKey.DialogMainButtonText] = Colors.White,
	[StyleKey.DialogMainButtonTextDisabled] = FFlagDevFrameworkFixButtonStyles and Colors.White or Color3.fromRGB(102, 102, 102),
	[StyleKey.DimmedText] = Color3.fromRGB(136, 136, 136),

	[StyleKey.ErrorText] = Colors.Red,

	[StyleKey.InputFieldBackground] = Colors.White,
	[StyleKey.InputFieldBackgroundDisabled] = Color3.fromRGB(231, 231, 231),
	[StyleKey.InputFieldBorder] = Color3.fromRGB(200, 200, 200),
	[StyleKey.InputFieldBorderDisabled] = Color3.fromRGB(182, 182, 182),
	[StyleKey.InputFieldBorderSelected] = Color3.fromRGB(102, 145, 220),
	[StyleKey.ItemHovered] = Colors.Gray,
	[StyleKey.ItemSelected] = Colors.Blue_Dark,

	[StyleKey.LinkText] = Colors.Blue_Light,

	[StyleKey.MainBackground] = Colors.White,
	[StyleKey.MainButton] = Color3.fromRGB(228, 238, 254),
	[StyleKey.MainText] = Colors.Black,
	[StyleKey.MainTextDisabled] = Color3.fromRGB(120, 120, 120),
	[StyleKey.MainTextHover] = Colors.Black,
	[StyleKey.MainTextSelected] = Colors.White,
	[StyleKey.Mid] = Color3.fromRGB(238, 238, 238),
	[StyleKey.SubBackground] = Colors.Gray_Lighter,
	[StyleKey.SubBackground2] = Colors.Gray_Lightest,

	[StyleKey.RibbonTab] = Color3.fromRGB(243, 243, 243),

	[StyleKey.ScrollBarBackground] = Color3.fromRGB(238, 238, 238),
	[StyleKey.ScrollBar] = FFlagDevFrameworkRefactorScrollbarColor and Colors.Gray_Light or Colors.White,
	[StyleKey.SliderKnobColor] = Colors.White,
	[StyleKey.SliderKnobImage] = "rbxasset://textures/DeveloperFramework/slider_knob_light.png",
	[StyleKey.SliderBackground] = Color3.fromRGB(204, 204, 204),
	[StyleKey.SubText] = Color3.fromRGB(170, 170, 170),

	[StyleKey.TitlebarText] = Colors.Black,
	[StyleKey.ToggleOnImage] = "rbxasset://textures/RoactStudioWidgets/toggle_on_light.png",
	[StyleKey.ToggleOffImage] = "rbxasset://textures/RoactStudioWidgets/toggle_off_light.png",
	[StyleKey.ToggleDisabledImage] = "rbxasset://textures/RoactStudioWidgets/toggle_disable_light.png",

	-- Remove with FFlagDevFrameworkCheckbox
	[StyleKey.CheckboxDefaultImage] = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_light.png",
	[StyleKey.CheckboxSelectedImage] = "rbxasset://textures/DeveloperFramework/checkbox_checked_light.png",

	[StyleKey.CheckboxUncheckedImage] = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_light.png",
	[StyleKey.CheckboxCheckedImage] = "rbxasset://textures/DeveloperFramework/checkbox_checked_light.png",
	[StyleKey.CheckboxIndeterminateImage] = "rbxasset://textures/DeveloperFramework/checkbox_indeterminate_light.png",
	[StyleKey.CheckboxDisabledImage] = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_disabled_light.png",

	[StyleKey.WarningText] = Color3.fromRGB(255, 128, 0),

	Font = Enum.Font.SourceSans,
	TextSize = 18,
}