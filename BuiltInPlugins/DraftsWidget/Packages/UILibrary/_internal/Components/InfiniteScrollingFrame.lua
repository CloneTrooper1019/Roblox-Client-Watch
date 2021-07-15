--[[
	A scroll frame that will check the left space between currently rendered asset
    When scrolling down, it will try to re-render. If we found less than defined space or empty space 
    between the render asset and the canvas, then we will try to call request more function defined in the property 
    to fetch more assets. The function is responsible for the paging method to fetch more assets.
    After the asset is returned, we will re-calculate canvase size.
	This component will send out request to try to load more pages on didMount and after didUpdate.

	Required Properties:
		function NextPageFunc - called during re-render when there is more empty spaces. This function should includes all the
			parameters needed for the request except for the currentPage. Target page will be determined by the infiScroller.

	Optional Properties:
		UDim2 Position - The position of the scrolling frame.
		UDim2 Size - The size of the scrolling frame.
		int LayoutOrder - sets order of element in layout
		int NextPageRequestDistance - space left in layout before making request to fetch more elements
		int CanvasHeight - used to specify height of canvas.
		Roact ref LayoutRef - used to calculate the height of the canvas.
		Color3 BackgroundColor - If provided, we show this color as the background of the frame with BackgroundTransparency = 0
]]
local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local StyledScrollingFrame = require(Library.Components.StyledScrollingFrame)

local InfiniteScrollingFrame = Roact.PureComponent:extend("InfiniteScrollingFrame")

local DEFAULT_CANVAS_HEIGHT = 900

local DEFAULT_REQUEST_DISTANCE = 0

function InfiniteScrollingFrame:init(props)
	self.state = {
		isRequestingNextPage = false,
	}

	self.isRequestingNextPage = false

	self.scrollingFrameRef = Roact.createRef()

	self.checkCanvasAndRequest = function()
		local scrollingFrame = self.scrollingFrameRef.current
		if not scrollingFrame then return end

		local canvasY = scrollingFrame.CanvasPosition.Y
		local windowHeight = scrollingFrame.AbsoluteWindowSize.Y
        local canvasHeight = scrollingFrame.CanvasSize.Y.Offset

        local requestDistance = self.props.NextPageRequestDistance or DEFAULT_REQUEST_DISTANCE

		-- Where the bottom of the scrolling frame is relative to canvas size
		local bottom = canvasY + windowHeight
		local dist = canvasHeight - bottom

		if dist <= requestDistance and not self.state.isRequestingNextPage then
			self.isRequestingNextPage = true
			self.requestNextPage()
		end
	end

	self.onScroll = function()
		self.checkCanvasAndRequest(self)
	end

	self.requestNextPage = function()
		self.props.NextPageFunc()
	end
end

function InfiniteScrollingFrame:didMount()
	self.checkCanvasAndRequest(self)
end

function InfiniteScrollingFrame:didUpdate(previousProps, previousState)
	-- check if request has fetched more children
	if previousState.isRequestingNextPage then
		for k,v in pairs(self.props[Roact.Children]) do
			if v ~= previousProps[Roact.Children][k] then
				self.isRequestingNextPage = false
				self.checkCanvasAndRequest(self)
			end
		end
	end
end

function InfiniteScrollingFrame:render()
	local props = self.props

	local nextPageFunc = self.props.NextPageFunc

	assert(nextPageFunc ~= nil and type(nextPageFunc) == "function",
		"InfiniteScrollingFrame requires a NextPageFunc function.")

    local position = props.Position
    local size = props.Size
    local layoutOrder = props.LayoutOrder

    local layout= props.LayoutRef and props.LayoutRef.current
	local canvasHeight = DEFAULT_CANVAS_HEIGHT
	if layout then
		canvasHeight = layout.AbsoluteContentSize.Y
	elseif props.CanvasHeight then
		canvasHeight = props.CanvasHeight
	end
	
	local backgroundColor = props.BackgroundColor

    return Roact.createElement(StyledScrollingFrame, {
        Position = position,
		Size = size,
		LayoutOrder = layoutOrder,
		CanvasSize = UDim2.new(1, 0, 0, canvasHeight),
		ZIndex = 1,
		BackgroundColor = backgroundColor,

		ScrollingEnabled = true,

		OnScroll = self.onScroll,

        [Roact.Ref] = self.scrollingFrameRef,
    }, props[Roact.Children])
end

return InfiniteScrollingFrame
