--[[
	An InfiniteScrollingFrame with callbacks to load more items.
	A thin wrapper around the infinite-scroller library with DeveloperFramework theming and naming conventions.

	Required Props:
		array[any] Items: The items to scroll through.
		callback RenderItem: Callback to render each item that should be visible.
			The items should have LayoutOrder set.

	Optional Props:
		Theme Theme: the theme supplied from mapToProps()
		Style Style: a style table supplied from props and theme:getStyle()
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		UDim2 Position: The position of the scrolling frame.
		UDim2 Size: The size of the scrolling frame.
		integer LayoutOrder: The order this component will display in a UILayout.
		number ItemPadding: The padding between items, in pixels.
		callback ItemIdentifier: Should return a persistent ID for each item. Defaults to object identity.
		callback LoadNext: Called when scrolled to the end of the itemList (index #itemList).
		callback LoadPrevious: Called when scrolled to the start of the itemList (index 1).
		number EstimatedItemSize: An initial guess at the average size of an item.
		number LoadingBuffer: The minimum number of unmounted elements to keep at the top and bottom of the list.
			If there are fewer than this, call LoadNext or LoadPrevious.
		number FocusIndex: The index of the initial element to focus on.
		boolean ShouldFocus: Toggle this to true to force a re-focus on the item at FocusIndex.
		UDim AnchorLocation: The position within the view to keep still as other things move.
			The Scale is relative to the size of the scrolling frame.
		callback OnScrollUpdate: Called whenever the scroller updates.
			OnScrollUpdate({leadIndex: number, anchorIndex: number, trailIndex: number, animationActive: boolean})

	Style Values:
		string BottomImage: The image that appears in the bottom 3rd of the scrollbar
		string MidImage: The image that appears in the middle 3rd of the scrollbar
		string TopImage: The image that appears in the top 3rd of the scrollbar
		integer ScrollBarPadding: The padding which appears on either side of the scrollbar.
		integer ScrollBarThickness: The horizontal width of the scrollbar.
		boolean ScrollingEnabled: Whether scrolling in this frame will change the CanvasPosition.
]]
local Framework = script.Parent.Parent
local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local FlagsList = Util.Flags.new({
	FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
})

local Roact = require(Framework.Parent.Roact)

local isUsedAsPackage = require(Framework.Util.isUsedAsPackage)

local InfiniteScroller
local InfiniteScrollerIsInstalledInParent = Framework.Parent:FindFirstChild("InfiniteScroller")
if FlagsList:get("FFlagStudioDevFrameworkPackage") and isUsedAsPackage() and InfiniteScrollerIsInstalledInParent then
	InfiniteScroller = require(Framework.Parent.InfiniteScroller :: any)
else
	InfiniteScroller = require(Framework.packages.InfiniteScroller :: any)
end

local Cryo = require(Framework.Parent.Cryo)

local ContextServices = require(Framework.ContextServices)
local Container = require(script.Parent.Container)
local Typecheck = Util.Typecheck

local InfiniteScrollingFrame = Roact.PureComponent:extend("InfiniteScrollingFrame")
Typecheck.wrap(InfiniteScrollingFrame, script)

function InfiniteScrollingFrame:init()
	self.state = {
		focusLockToken = 1
	}

	self.propFilters = {
		containerProps = {
			Position = Cryo.None,
			Size = Cryo.None,
			LayoutOrder = Cryo.None,
			Theme = Cryo.None,
			Style = Cryo.None,
		},
		wrapperProps = {
			ItemPadding = Cryo.None,
			ItemIdentifier = Cryo.None,
			LoadNext = Cryo.None,
			LoadPrevious = Cryo.None,
			EstimatedItemSize = Cryo.None,
			LoadingBuffer = Cryo.None,
			FocusIndex = Cryo.None,
			ShouldFocus = Cryo.None,
			AnchorLocation = Cryo.None,
			OnScrollUpdate = Cryo.None,
			RenderItem = Cryo.None,
			Items = Cryo.None,
		}
	}

	self.getInfiniteScrollingFrameProps = function(props, style)
		-- After filtering out parent's props and DeveloperFramework-specific props (such as Style and Theme),
		-- what is left are infinite-scroller props
		local updatedProps
		if THEME_REFACTOR then
			updatedProps = Cryo.Dictionary.join(props, {
				Stylizer = Cryo.None
			})
		else
			updatedProps = props
		end
		return Cryo.Dictionary.join(
			style,
			updatedProps,
			self.propFilters.containerProps,
			self.propFilters.wrapperProps,
			{
				Size = UDim2.new(1, 0, 1, 0),
				[Roact.Children] = Cryo.None,
				itemList = props.Items,
				renderItem = props.RenderItem,
				loadNext = props.LoadNext,
				loadPrevious = props.LoadPrevious,
				padding = props.ItemPadding,
				identifier = props.ItemIdentifier,
				loadingBuffer = props.LoadingBuffer,
				focusIndex = self.state.focusLockToken,
				anchorLocation = props.AnchorLocation or UDim.new(1, 0),
				onScrollUpdate = props.OnScrollUpdate
			})
	end
end

function InfiniteScrollingFrame:didUpdate(prevProps, prevState)
	if not prevProps.ShouldFocus and self.props.ShouldFocus then
		self:setState({
			focusLockToken = prevState.focusLockToken + 1
		})
	end
end

function InfiniteScrollingFrame:render()
	local props = self.props
	local theme = props.Theme

	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local position = props.Position
	local size = props.Size
	local layoutOrder = props.LayoutOrder

	return Roact.createElement(Container, {
		Position = position,
		Size = size,
		LayoutOrder = layoutOrder,
	}, {
		InfiniteScroller = Roact.createElement(
			InfiniteScroller.Scroller,
			self.getInfiniteScrollingFrameProps(self.props, style)
		),
	})
end

ContextServices.mapToProps(InfiniteScrollingFrame, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return InfiniteScrollingFrame