--[[
	Public interface for UI
]]

local Src = script

local strict = require(Src.Parent.Util.strict)

local FrameworkStyles = require(Src.FrameworkStyles)

local Image = require(Src.Image)
local Box = require(Src.Box)
local RoundBox = require(Src.RoundBox)
local Container = require(Src.Container)
local DropdownMenu = require(Src.DropdownMenu)
local Button = require(Src.Button)
local LoadingBar = require(Src.LoadingBar)
local LoadingIndicator = require(Src.LoadingIndicator)
local ExpandableWidget = require(Src.ExpandableWidget)
local FakeLoadingBar = require(Src.FakeLoadingBar)
local HoverArea = require(Src.HoverArea)
local CaptureFocus = require(Src.CaptureFocus)
local ShowOnTop = require(Src.ShowOnTop)
local DragListener = require(Src.DragListener)
local DropShadow = require(Src.DropShadow)
local KeyboardListener = require(Src.KeyboardListener)
local LinkText = require(Src.LinkText)
local Pane = require(Src.Pane)
local PageNavigation = require(Src.PageNavigation)
local PaginatedTable = require(Src.PaginatedTable)
local IconButton = require(Src.IconButton)
local ToggleButton = require(Src.ToggleButton)
local Tooltip = require(Src.Tooltip)
local RangeSlider = require(Src.RangeSlider)
local RadioButton = require(Src.RadioButton)
local RadioButtonList = require(Src.RadioButtonList)
local Table = require(Src.Table)
local TableRow = require(Src.TableRow)
local Tabs = require(Src.Tabs)
local TextLabel = require(Src.TextLabel)
local TextWithInlineLink = require(Src.TextWithInlineLink)
local TextInput = require(Src.TextInput)
local TextInputDialog = require(Src.TextInputDialog)
local TreeTable = require(Src.TreeTable)
local TreeView = require(Src.TreeView)
local InstanceTreeView = require(Src.InstanceTreeView)
local BulletList = require(Src.BulletList)
local ScrollingFrame = require(Src.ScrollingFrame)
local SelectInput = require(Src.SelectInput)
local Separator = require(Src.Separator)
local SimpleTab = require(Src.SimpleTab)
local Slider = require(Src.Slider)
local InfiniteScrollingFrame = require(Src.InfiniteScrollingFrame)
local MultiLineTextInput = require(Src.MultiLineTextInput)
local Checkbox = require(Src.Checkbox)

-- NOTE: Please keep components in alphabetical order
local UI = strict({
	-- Empty default styles for Framework components
	FrameworkStyles = FrameworkStyles,

	-- UI Components
	BulletList = BulletList,
	Button = Button,
	CaptureFocus = CaptureFocus,
	Checkbox = Checkbox,
	Container = Container,
	DragListener = DragListener,
	DropdownMenu = DropdownMenu,
	DropShadow = DropShadow,
	ExpandableWidget = ExpandableWidget,
	FakeLoadingBar = FakeLoadingBar,
	HoverArea = HoverArea,
	IconButton = IconButton,
	InfiniteScrollingFrame = InfiniteScrollingFrame,
	InstanceTreeView = InstanceTreeView,
	KeyboardListener = KeyboardListener,
	LinkText = LinkText,
	LoadingBar = LoadingBar,
	LoadingIndicator = LoadingIndicator,
	MultiLineTextInput = MultiLineTextInput,
	Pane = Pane,
	PageNavigation = PageNavigation,
	PaginatedTable = PaginatedTable,
	RadioButton = RadioButton,
	RadioButtonList = RadioButtonList,
	RangeSlider = RangeSlider,
	ScrollingFrame = ScrollingFrame,
	SelectInput = SelectInput,
	Separator = Separator,
	SimpleTab = SimpleTab,
	ShowOnTop = ShowOnTop,
	Slider = Slider,
	Table = Table,
	TableRow = TableRow,
	Tabs = Tabs,
	TextInput = TextInput,
	TextInputDialog = TextInputDialog,
	TextWithInlineLink = TextWithInlineLink,
	ToggleButton = ToggleButton,
	Tooltip = Tooltip,
	TreeTable = TreeTable,
	TreeView = TreeView,

	Decoration = {
		Box = Box,
		Image = Image,
		RoundBox = RoundBox,
		TextLabel = TextLabel,
	},
})

return UI
