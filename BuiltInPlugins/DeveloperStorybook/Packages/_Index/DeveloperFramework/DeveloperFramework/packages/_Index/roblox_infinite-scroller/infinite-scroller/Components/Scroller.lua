local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Root = script:FindFirstAncestor("infinite-scroller").Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local t = require(Root.t)
local Otter = require(Root.Otter)

local FitFrame = require(Root.FitFrame).FitFrameOnAxis
local findNewIndices = require(script.Parent.findNewIndices)
local relocateIndices = require(script.Parent.relocateIndices)
local Round = require(script.Parent.Round)
local Distance = require(script.Parent.Distance)
local KeyPool = require(script.Parent.KeyPool)

local Logger = require(script.Parent.Logger)
local TimeLogger = require(script.Parent.TimeLogger)

local NotifyReady = require(script.Parent.NotifyReady)

local Scroller = Roact.PureComponent:extend("Scroller")

Scroller.Orientation = require(script.Parent.Orientation)

local MOTOR_OPTIONS = {
	frequency = 4,
	dampingRatio = 1,
}

local REPORT_TRIMMING_ERROR_THRESHOLD = 3

local isVertical = {
	[Scroller.Orientation.Up] = true,
	[Scroller.Orientation.Down] = true,
	[Scroller.Orientation.Left] = false,
	[Scroller.Orientation.Right] = false,
}

local isReverse = {
	[Scroller.Orientation.Up] = true,
	[Scroller.Orientation.Down] = false,
	[Scroller.Orientation.Left] = true,
	[Scroller.Orientation.Right] = false,
}

local direction = {
	[Scroller.Orientation.Up] = -1,
	[Scroller.Orientation.Down] = 1,
	[Scroller.Orientation.Left] = -1,
	[Scroller.Orientation.Right] = 1,
}

Scroller.validateProps = t.interface({
	-- Required. The list of items to scroll through.
	itemList = t.array(t.any),

	-- Required. A callback function, called with each visible item in the itemList when the list is rendered.
	renderItem = t.callback,

	-- A function to uniquely identify list items. Calling this on the same item twice should give the same result
	-- accoring to ==.
	identifier = t.optional(t.callback),

	-- One of the Scroller.Orientation enums. Determines the leading edge of the infinite scroll.
	orientation = t.optional(Scroller.Orientation.isOrientation),

	-- A callback function, called when the infinite scroll reaches the leading end of the itemList (index
	-- #itemList).
	loadNext = t.optional(t.callback),

	-- A callback function, called when the infinite scroll reaches the trailing end of the itemList (index 1).
	loadPrevious =  t.optional(t.callback),

	-- Padding between elements in the scrolling frame. The Scale is relative to the size of the scrolling frame.
	padding = t.optional(t.UDim),

	-- The minimum number of unmounted elements to keep at the top and bottom of the list. If there are fewer than
	-- this call loadNext or loadPrevious.
	loadingBuffer = t.optional(t.numberPositive),

	-- The amount of space above and below the view to render items in.
	mountingBuffer = t.optional(t.numberPositive),

	-- The amount of empty space past the leading element of the list. The Scale is relative to the size of the scrolling frame.
	leadBuffer = t.optional(t.UDim),

	-- The amount of empty space past the trailing element of the list. The Scale is relative to the size of the scrolling frame.
	trailBuffer = t.optional(t.UDim),

	-- An initial guess at the average size of an item.
	estimatedItemSize = t.optional(t.numberPositive),

	-- The maximum distance to search for moved elements.
	maximumSearchDistance = t.optional(t.numberPositive),

	-- The element to put in focus initially.
	focusIndex = t.optional(t.integer),

	-- An arbitrary value to prevent the list from refocusing every render. Change this to cause the list to reset
	-- and refocus on the new focusIndex.
	focusLock = t.optional(t.any),

	-- The position within the view to keep still as other things move. The Scale is relative to the size of the
	-- scrolling frame.
	anchorLocation = t.optional(t.UDim),

	-- Animate the scrolling
	animateScrolling = t.optional(t.boolean),

	--Animation options
	animateOptions = t.optional(t.table),

	-- Properties that should trigger rerenders of the children elements even though the scroller itself does not
	-- use them.
	extraProps = t.optional(t.table),

	-- A callback function that will update the index change
	onScrollUpdate = t.optional(t.callback),

	-- Which components to disable instance recycling for.
	recyclingDisabledFor = t.optional(t.array(t.string)),

	---- INTERNAL ONLY ----
	[NotifyReady] = t.any,
})

-- Default values for all the infinite-scroller-specific props. Any prop not in this list will be passed on to the
-- underlying ScrollingFrame.
Scroller.defaultProps = {
	itemList = {},
	renderItem = {},
	identifier = function(item)
		return item
	end,
	orientation = Scroller.Orientation.Down,
	loadNext = function() end,
	loadPrevious = function() end,
	padding = UDim.new(),
	loadingBuffer = 10,
	mountingBuffer = 200,
	leadBuffer = UDim.new(),
	trailBuffer = UDim.new(),
	estimatedItemSize = 50,
	maximumSearchDistance = 100,
	focusIndex = 1,
	focusLock = {},
	anchorLocation = UDim.new(0, 0),
	animateScrolling = false,
	animateOptions = MOTOR_OPTIONS,
	extraProps = {},
	onScrollUpdate = function() end,
	recyclingDisabledFor = {},
	[NotifyReady] = false,
}

function Scroller:render()
	self.log:debug("render")

	-- Gather vertical/horizontal specific variables.
	local axis = isVertical[self.props.orientation] and {
		fillDirection = Enum.FillDirection.Vertical,
		scrollDirection = Enum.ScrollingDirection.Y,
		fitDirection = FitFrame.Axis.Vertical,
		minimumSize = UDim2.new(1, 0, 0, 0),
		canvasSize = UDim2.new(0, 0, 0, self.state.size),
		paddingSize = UDim2.new(0, 0, 0, self.state.padding),
	} or {
		fillDirection = Enum.FillDirection.Horizontal,
		scrollDirection = Enum.ScrollingDirection.X,
		fitDirection = FitFrame.Axis.Horizontal,
		minimumSize = UDim2.new(0, 0, 1, 0),
		canvasSize = UDim2.new(0, self.state.size, 0, 0),
		paddingSize = UDim2.new(0, self.state.padding, 0, 0),
	}

	-- Remove non-standard props from list to pass on to ScrollingFrame. These are the same props given in
	-- defaultProps.
	local props = Cryo.Dictionary.join(
		self.props,
		self.propsToClear,
		{
			CanvasSize = axis.canvasSize,
			ScrollingDirection = axis.scrollDirection,
			[Roact.Change.CanvasPosition] = self.onScroll,
			[Roact.Change.AbsoluteSize] = self.onResize,
			[Roact.Ref] = self:getRef(),
		}
	)

	local children = {
		layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = axis.fillDirection,
			Padding = UDim.new(0, self.itemPadding),
			[Roact.Change.AbsoluteContentSize] = self.onContentResize,
		}),
		padding = Roact.createElement("Frame", {
			Size = axis.paddingSize,
			LayoutOrder = -1 - (self.state.listSize or 0),
			BackgroundTransparency = 1,
		}),
	}

	-- Trailing and leading indicies won't be set if this isn't true.
	if self.state.ready and not Cryo.isEmpty(self.props.itemList) then
		self.log:trace("  Rendering elements between {} and {}", self.state.trail.index, self.state.lead.index)
		for n = self.state.trail.index, self.state.lead.index do
			local metadata = self:getMetadata(n)
			children[metadata.name] = Roact.createElement(FitFrame, {
				minimumSize = axis.minimumSize,
				axis = axis.fitDirection,
				FillDirection = axis.fillDirection,
				BackgroundTransparency = 1,
				LayoutOrder = isReverse[self.props.orientation] and -n or n,
				[Roact.Ref] = metadata.ref,
			}, {
				item = self.props.renderItem(self.props.itemList[n], false),
			})
		end
	end

	return Roact.createElement("ScrollingFrame", props, children)
end

function Scroller:shouldUpdate(nextProps, nextState)
	if not self.alive then
		return false
	end

	self.log:trace("shouldUpdate")

	if self.props["Size"] ~= nextProps["Size"] then
		self.log:trace("  Size Prop Changed")
		self._sizePropChanged = true
	end

	-- Check for state and props changes in the same way PureComponent would,
	-- but go one more level down for extraProps.
	if nextState ~= self.state then
		self.log:trace("  State changed")
		return true
	end

	for key, value in pairs(nextProps) do
		if self.props[key] ~= value then
			if key ~= "extraProps" then
				self.log:trace("  Prop changed: {}", key)
				return true
			end

			for extraKey, extraValue in pairs(value) do
				if self.props.extraProps[extraKey] ~= extraValue then
					self.log:trace("  Extra prop changed: {}", extraKey)
					return true
				end
			end
		end
	end

	for key, value in pairs(self.props) do
		if nextProps[key] ~= value then
			if key ~= "extraProps" then
				self.log:trace("  Prop changed: {}", key)
				return true
			end

			for extraKey, extraValue in pairs(value) do
				if nextProps.extraProps[extraKey] ~= extraValue then
					self.log:trace("  Extra prop changed: {}", extraKey)
					return true
				end
			end
		end
	end

	return false
end

function Scroller:willUpdate(nextProps, nextState)
	if not self.alive then
		return
	end

	self.log:debug("willUpdate")

	if not nextState.ready then
		return
	end

	if self.updating then
		self.timeLog:info("Middle of update")
	else
		self.timeLog:info("Start of update")

		-- Reset error counters
		self.numberOfTopTrims = 0
		self.numberOfBottomTrims = 0
		self.lastTrimTop = 0
		self.lastTrimBottom = 0
	end
	self.updating = true

	self.sizeDebounce = true

	local deletions = {}
	local additions = {}

	if not Cryo.isEmpty(self.props.itemList) and self.state.lead then
		for n = self.state.trail.index, self.state.lead.index do
			local id = self.props.identifier(self.props.itemList[n])
			deletions[id] = true
		end
	end

	if not Cryo.isEmpty(nextProps.itemList) and nextState.lead then
		for n = nextState.trail.index, nextState.lead.index do
			local item = nextProps.itemList[n]
			local id = nextProps.identifier(item)
			if deletions[id] then
				-- Element is in both ranges.
				deletions[id] = nil
			else
				additions[id] = item
			end
		end
	end

	-- Clear names first, so new items can use them.
	for id, _ in pairs(deletions) do
		self:clearMetadata(id)
	end
	for id, item in pairs(additions) do
		self:updateMetadata(id, item, nextProps)
	end

	-- The focus lock changed, clear the non-state anchor variables.
	if self.state.lastFocusLock ~= nextState.lastFocusLock then
		self.scrollDebounce = true
		self.motorActive = false
		self.anchorFramePosition = 0
		if self.state.listSize and self.state.listSize > nextState.listSize then
			-- Perform a full reset when the list decreases in size to ensure the canvas
			-- is sized properly
			self.anchorCanvasPosition = self.relativeAnchorLocation
		else
			-- The canvas hasn't necessarily been reset in size here, so we need to convert the frame
			-- coordinates of relativeAnchorLocation to canvas coordinates.
			self.anchorCanvasPosition = self:frameToCanvasPosition(self.relativeAnchorLocation)
		end
	end
end

function Scroller:didUpdate(previousProps, previousState)
	if not self.alive then
		return
	end

	self.log:debug("didUpdate")

	if Cryo.isEmpty(self.props.itemList) then
		return
	end

	if not self.state.ready then
		self.onResize(self:getRef().current)
		return
	end

	if self.props.focusIndex ~= previousProps.focusIndex and
		self.props.focusLock ~= previousProps.focusLock then

			self.indexChanged = {
				oldIndex = previousProps.focusIndex,
				newIndex = self.props.focusIndex,
				lastFocusLock = self.props.focusLock,
			}
			self.motorActive = false

			self.log:trace("self.props.focusIndex {}", self.props.focusIndex)
			self.log:trace("self.state.anchor.index {}", self.state.anchor.index)
			self.log:trace("previousState.anchor.index {}", previousState.anchor.index)
	end

	local adjustedCanvas = self:adjustCanvas(self.scrollingForward, self.scrollingBackward)
	if not adjustedCanvas then
		if self.indexChanged and self.props.animateScrolling then
			self:scrollToAnchor()
		else
			self:moveToAnchor()
		end

		if self.anchorOffset ~= 0 then
			self:setState({})
			return
		end

		-- The canvas has finished adjusting itself after a resize
		self.resized = false

		self:loadMore()
		self.sizeDebounce = false

		if self.updating then
			self.timeLog:info("End of update")
		end
		self.updating = false

		--Return the updated index
		if self.props.onScrollUpdate then
			self.props.onScrollUpdate({
				leadIndex = self.state.lead.index,
				anchorIndex = self.state.anchor.index,
				trailIndex = self.state.trail.index,
				animationActive = self.motorActive,
			})
		end
	end

	self._sizePropChanged = false

	self.prevCycle = {
		frameSize = self:measure(self:getCurrent().AbsoluteSize),
		canvasSize = self.state.size,
		canvasPosition = Round.nearest(self:measure(self:getCurrent().CanvasPosition)),
		relativeAnchorLocation = self.relativeAnchorLocation,
	}
end

function Scroller.getDerivedStateFromProps(nextProps, lastState)
	-- No self in static functions
	Logger:trace("getDerivedStateFromProps")

	if not lastState.ready or Cryo.isEmpty(nextProps.itemList) then
		return nil
	end

	local listSize = #nextProps.itemList
	local lastFocusLock = nil

	-- Reset the state if the focus lock changes. This is guaranteed to be true the first time.
	if lastState.lastFocusLock ~= nextProps.focusLock then
		Logger:trace("  Resetting focus lock {} to {}", lastState.lastFocusLock, nextProps.focusLock)
		if nextProps.animateScrolling and lastState.lastFocusLock ~= nil then
			lastFocusLock = nextProps.focusLock
		else
			local focusID = nextProps.identifier(nextProps.itemList[nextProps.focusIndex])
			return {
				listSize = listSize,
				trail = {index=nextProps.focusIndex, id=focusID},
				anchor = {index=nextProps.focusIndex, id=focusID},
				lead = {index=nextProps.focusIndex, id=focusID},
				padding = 0,
				size = 0,
				lastFocusLock = nextProps.focusLock,
			}
		end
	end

	local trailIndex, anchorIndex, leadIndex = findNewIndices(nextProps, lastState)
	Logger:trace("  Trailing index moved from {} to {}", lastState.trail.index, trailIndex)
	Logger:trace("  Anchor index moved from {} to {}", lastState.anchor.index, anchorIndex)
	Logger:trace("  Leading index moved from {} to {}", lastState.lead.index, leadIndex)

	-- Nothing changed. Return early to avoid triggering an update.
	if anchorIndex and lastState.anchor.index == anchorIndex
		and trailIndex and lastState.trail.index == trailIndex
		and leadIndex and lastState.lead.index == leadIndex then
			Logger:trace("  No change, returning early")
			if listSize == lastState.listSize then
				if lastFocusLock then
					return {
						lastFocusLock = lastFocusLock,
					}
				else
					return nil
				end
			else
				return {
					listSize = listSize,
					lastFocusLock = lastFocusLock,
				}
			end
	end

	-- TODO #51 findNewIndices, state and this should all agree on a format
	local newIndices = relocateIndices(
		{trailIndex=trailIndex, anchorIndex=anchorIndex, leadIndex=leadIndex},
		{trailIndex=lastState.trail.index, anchorIndex=lastState.anchor.index, leadIndex=lastState.lead.index},
		listSize
	)

	Logger:trace("  Anchor index moved to {}", newIndices.anchorIndex)
	Logger:trace("  Trailing index moved to {}", newIndices.trailIndex)
	Logger:trace("  Leading index moved to {}", newIndices.leadIndex)

	local trailID = nextProps.identifier(nextProps.itemList[newIndices.trailIndex])
	local anchorID = nextProps.identifier(nextProps.itemList[newIndices.anchorIndex])
	local leadID = nextProps.identifier(nextProps.itemList[newIndices.leadIndex])

	return {
		listSize = listSize,
		trail = {index=newIndices.trailIndex, id=trailID},
		anchor = {index=newIndices.anchorIndex, id=anchorID},
		lead = {index=newIndices.leadIndex, id=leadID},
		lastFocusLock = lastFocusLock,
	}
end

function Scroller:init()
	self.guid = HttpService:GenerateGUID()
	self.log = Logger:new(script:GetFullName() .. "." .. self.guid)
	self.timeLog = TimeLogger:new(script:GetFullName() .. "." .. self.guid)

	self.log:debug("init")

	-- Only self:getRef() should access this.
	self._ref = Roact.createRef()

	self.motorPrevValue = 0

	self.motorOnStep = function(value)
		self.log:trace("onStep {}", value)
		if not self.motorActive or self.indexChanged == nil then
			self.motor:stop()
			return
		end
		local currentValue = self.indexChanged.currentPos
		if currentValue == nil then
			self.motor:stop()
			return
		end
		local diff = value - self.motorPrevValue
		if self:getCurrent() then
			self:scrollRelative(diff)
			self.motorPrevValue = value
		end
	end

	self.motorOnComplete = function()
		self.log:trace("otter onComplete")
		self.motorActive = false
		--Return the updated index
		if self.props.onScrollUpdate then
			self.props.onScrollUpdate({
				leadIndex = self.props.focusIndex,
				anchorIndex = self.props.focusIndex,
				trailIndex = self.props.focusIndex,
				animationActive = self.motorActive,
			})
		end
		self.motorPrevValue = 0
		self.indexChanged = nil
		if self.motor then
			self.motor:destroy()
		end
	end

	self.motorActive = false
	self.springLock = 0
	self.scrollDebounce = false
	self.sizeDebounce = true

	--Used to track index changes
	self.indexChanged = nil

	self.onScroll = function(rbx)
		self.log:trace("onScroll")
		if not self.alive or self.resized then
			return
		end

		self.log:trace("  CanvasPosition is {}", rbx.CanvasPosition)
		if self.scrollDebounce then
			self.log:trace("  Debouncing scroll")
			return
		end

		local delta, newState = self:recalculateAnchor()
		self.scrollingBackward = delta < 0
		self.scrollingForward = delta > 0
		self.log:trace("  Delta is {}", delta)

		newState = Cryo.Dictionary.join(
			newState,
			self:resetAnchorPosition(newState),
			self:recalculateBounds(self.scrollingForward, self.scrollingBackward, newState)
		)

		if not Cryo.isEmpty(newState) then
			self:setState(newState)
		end

		-- Handle any passed in scroll callback.
		if self.props[Roact.Change.CanvasPosition] then
			self.props[Roact.Change.CanvasPosition](rbx)
		end

		self.prevCycle.canvasPosition = Round.nearest(self:measure(rbx.CanvasPosition))
	end

	self.onResize = function(rbx)
		self.log:trace("onResize")
		if not self.alive then
			return
		end

		local size = self:measure(rbx.AbsoluteSize)
		local pos = self:measure(rbx.AbsolutePosition)

		self.leadBufferPx = Round.nearest(
			self.props.leadBuffer.Scale * size + self.props.leadBuffer.Offset)

		self.trailBufferPx = Round.nearest(
			self.props.trailBuffer.Scale * size + self.props.trailBuffer.Offset)

		self.itemPadding = self.props.padding.Scale * size + self.props.padding.Offset
		if isReverse[self.props.orientation] then
			self.relativeAnchorLocation = Round.nearest(
				self.props.anchorLocation.Scale * size + self.props.anchorLocation.Offset)
		else
			self.relativeAnchorLocation = Round.nearest(
				(1 - self.props.anchorLocation.Scale) * size - self.props.anchorLocation.Offset)
		end
		self.absoluteAnchorLocation = self.relativeAnchorLocation + pos
		self.mountAboveAnchor = self.relativeAnchorLocation + self.props.mountingBuffer
		self.mountBelowAnchor = size - self.relativeAnchorLocation + self.props.mountingBuffer
		self.resized = true
		self.increasedSize = self.state.size < size

		-- Handle any passed in resize callback.
		if self.props[Roact.Change.AbsoluteSize] then
			self.props[Roact.Change.AbsoluteSize](rbx)
		end

		if not self.state.ready then
			self.log:trace("  Setting initial anchor position to {}", self.relativeAnchorLocation)
			-- When setting this for the first time, set the frame position of the current anchor to 0,
			-- and its canvas position to equal where it should be in the frame. When the scroller goes
			-- to correct this, the anchor will end up in the right place with the right padding around it.
			self.anchorFramePosition = 0
			self.anchorCanvasPosition = self.relativeAnchorLocation

			coroutine.wrap(function()
				RunService.Heartbeat:Wait()
				if not self.state.ready and self.alive then
					self:setState({
						ready = true
					})

					-- This should only be set by tests.
					if self.props[NotifyReady] then
						self.props[NotifyReady]:Fire()
					end
				end
			end)()
		else
			self:handleResize(size)
		end
	end

	self.onContentResize = function()
		self.log:trace("onContentResize")

		if not self.alive or self.sizeDebounce or not self.state.ready or self:isScrollingWithElasticBehavior() then
			self.log:trace("  Skipping onContentResize")
			return
		end
		self:setState({})  -- Force a rerender.
	end

	self.anchorCanvasPosition = 0
	self.anchorFramePosition = 0
	self.anchorOffset = 0

	self.metadata = {}
	self.pools = {}
	self.refpool = {}

	self.scrollingBackward = false
	self.scrollingForward = false

	self.lastLoadPrevItems = nil
	self.lastLoadNextItems = nil

	self.alive = true
	self.updating = false

	-- Store the list of props to not pass on to the underlying scrolling frame.
	self.propsToClear = {}
	for k, _ in pairs(Scroller.defaultProps) do
		self.propsToClear[k] = Cryo.None
	end

	-- This will get updated shortly, but one render will happen before state.ready is set
	self:setState({
		ready = false,
		lastFocusLock = nil,
		padding = 0,
		size = 0,
	})
end

function Scroller:willUnmount()
	if self.motor then
		self.motor:destroy()
	end

	self.alive = false
end

-- Find which element is currently closest to the anchor position.
function Scroller:recalculateAnchor()
	self.log:trace("recalculateAnchor")

	-- Find the index of the element at the appropriate position
	local index = self:findIndexAt(
		self:absoluteToCanvasPosition(self.absoluteAnchorLocation), self.state.anchor.index, false)

	self.anchorCanvasPosition = self:getAnchorCanvasFromIndex(index)
	self.anchorFramePosition = self:getAnchorFrameFromIndex(index)

	local delta
	if index == self.state.anchor.index then
		self.log:trace("  Current anchor still works")
		return 0, {}
	elseif index < self.state.anchor.index then
		delta = -1
	else
		delta = 1
	end

	self.log:trace("  New anchor at index {}", index)

	-- Store the new anchor's details
	self.log:trace("  New anchor at canvas position {}", self.anchorCanvasPosition)
	self.log:trace("  New anchor at frame position {}", self.anchorFramePosition)
	return delta, {
		anchor = {index=index, id=self:getID(index)},
	}
end

-- Move all the rendered elements up or down to put the anchor back where it was.
function Scroller:resetAnchorPosition(newState)
	local anchor = newState and newState.anchor or self.state.anchor
	local padding = newState and newState.padding or self.state.padding

	self.log:trace("resetAnchorPosition")
	self.log:trace("  Anchor index is {}", anchor.index)
	local offset = self:getAnchorCanvasFromIndex(anchor.index)
	self.log:trace("  Anchor is at {}", offset)
	self.log:trace("  Anchor offset is {}", self.anchorOffset)
	local newPos = self.anchorCanvasPosition - self.anchorOffset
	self.log:trace("  Anchor should be at {}", newPos)
	local diff = Round.nearest(newPos - offset)
	if diff ~= 0 then
		self.log:trace("  Changing padding from {} to {}", padding, padding + diff)
		self.log:trace("  Changing anchorCanvasPosition from {} to {}", self.anchorCanvasPosition, Round.nearest(self.anchorCanvasPosition - self.anchorOffset))
		self.anchorCanvasPosition = Round.nearest(self.anchorCanvasPosition - self.anchorOffset)
		self.anchorOffset = 0
		return {padding = padding + diff}
	else
		return {}
	end
end

-- Get the current padding from the UIPadding child.
function Scroller:getCurrentPadding()
	local pad = self:getCurrent().padding
	-- Only one of these will be non-zero
	return pad.Size.X.Offset + pad.Size.Y.Offset
end

-- Move the top and bottom of the range to be rendered up and down to make sure
-- enough things are being rendered.
function Scroller:recalculateBounds(trimTrailing, trimLeading, newState)
	local lead = newState and newState.lead or self.state.lead
	local trail = newState and newState.trail or self.state.trail
	local anchor = newState and newState.anchor or self.state.anchor

	self.log:trace("recalculateBounds")
	self.log:trace("  Leading index was {}", lead.index)
	self.log:trace("  Trailing index was {}", trail.index)

	local anchorPos = self:getAnchorCanvasFromIndex(anchor.index)
	local mountTop = anchorPos - self.mountAboveAnchor
	local mountBottom = anchorPos + self.mountBelowAnchor
	self.log:trace("  Target for top at {}", mountTop)
	self.log:trace("  Target for bottom at {}", mountBottom)

	local topIndex = self:findIndexAt(mountTop, anchor.index, true)
	self.log:trace("  Found new top index at {}", topIndex)
	local bottomIndex = self:findIndexAt(mountBottom, anchor.index, true)
	self.log:trace("  Found new bottom index at {}", bottomIndex)

	local leadIndex = math.max(topIndex, bottomIndex)
	if leadIndex < lead.index and not trimLeading then
		leadIndex = lead.index
	end

	local trailIndex = math.min(topIndex, bottomIndex)
	if trailIndex > trail.index and not trimTrailing then
		trailIndex = trail.index
	end

	if trailIndex < trail.index or leadIndex > lead.index then
		self.log:trace("  Changing leading index to {}", leadIndex)
		self.log:trace("  Changing trailing index to {}", trailIndex)
		return {
			trail = {index=trailIndex, id=self:getID(trailIndex)},
			lead = {index=leadIndex, id=self:getID(leadIndex)},
		}
	else
		return {}
	end
end

-- Find the index of the element that overlaps the given canvas-relative position.
function Scroller:findIndexAt(targetPos, hintIndex, extrapolate)
	self.log:trace("  findIndexAt")
	-- Get the distance from the hinted index or the anchor.
	local currentIndex = hintIndex or self.state.anchor.index
	local currentDist = self:distanceToPosition(currentIndex, targetPos)
	self.log:trace("    Searching from index {}", currentIndex)
	self.log:trace("    Position is {} from {}", currentDist, targetPos)
	if currentDist == 0 then
		-- resolving border disputes
		local nextIndex = currentIndex + Round.awayFromZero(self.props.anchorLocation.Scale - 0.5)
		if nextIndex > self.state.listSize or nextIndex < 1 then
			return currentIndex
		end

		local nextDist = self:distanceToPosition(nextIndex, targetPos)
		if nextDist == 0 then
			return nextIndex
		end
		return currentIndex
	end

	-- Get the distance from one end of the list.
	local nextIndex = (currentDist < 0) and self.state.trail.index or self.state.lead.index
	self.log:trace("    Nearest end at {}", nextIndex)
	if currentIndex == nextIndex then
		self.log:trace("    Hint index already at end")
		-- If the target position lies outside of the loaded elements.
		if currentIndex + currentDist < self.state.trail.index
			or currentIndex + currentDist > self.state.lead.index then
			self.log:trace("    Target out of bounds")
			if not extrapolate then
				-- Do not extrapolate. Return the closest loaded element.
				return currentIndex
			end

			-- Extrapolate using the estimated item size.
			local delta = Round.awayFromZero(currentDist / self.props.estimatedItemSize)
			self.log:trace("    Estimating target at {} from end", delta)
			return math.min(math.max(currentIndex + delta, 1), self.state.listSize)
		end
	else
		local nextDist = self:distanceToPosition(nextIndex, targetPos)
		self.log:trace("    End is {} from target", nextDist)
		if nextDist == 0 then
			return nextIndex
		end

		-- If the target position lies outside of the loaded elements.
		if currentDist * nextDist > 0 then
			self.log:trace("    Target out of bounds")
			if not extrapolate then
				-- Do not extrapolate. Return the closest loaded element.
				return nextIndex
			end

			-- Extrapolate using the estimated item size.
			local delta = Round.awayFromZero(nextDist / self.props.estimatedItemSize)
			self.log:trace("    Estimating target at {} from end", delta)
			return math.min(math.max(nextIndex + delta, 1), self.state.listSize)
		end

		-- Jump to the approximate location of the target based on the distance from current and next.
		local totalDist = math.abs(currentDist) + math.abs(nextDist)
		local indexCount = math.abs(currentIndex - nextIndex)
		currentIndex = currentIndex + Round.nearest(indexCount * currentDist / totalDist)
		currentDist = self:distanceToPosition(currentIndex, targetPos)
		self.log:trace("    Interpolated index is {}", currentIndex)
		self.log:trace("    Distance from interpolated index is {}", currentDist)
	end

	-- Linear search from best guess index.
	while currentDist ~= 0 do
		if currentDist < 0 then
			currentIndex = currentIndex - 1
		else
			currentIndex = currentIndex + 1
		end
		currentDist = self:distanceToPosition(currentIndex, targetPos)
		self.log:trace("    Distance after step is {}", currentDist)
	end

	return currentIndex
end

function Scroller:findIndexWithRemainder(targetPos, hintIndex, extrapolate)
	local reverse = isReverse[self.props.orientation]
	local topBufferPx = reverse and self.leadBufferPx or self.trailBufferPx

	if targetPos < topBufferPx then
		local topIndex = reverse and self.state.listSize or 1
		return topIndex, 0
	elseif targetPos > Round.nearest(self:measure(self:getCurrent().CanvasSize).Offset) then
		local bottomIndex = reverse and 1 or self.state.listSize
		return bottomIndex, 0
	end

	local currentIndex = self:findIndexAt(targetPos, hintIndex, extrapolate)
	local actualIndexPosition = self:getAnchorCanvasFromIndex(currentIndex)
	local nextIndex = currentIndex + Round.awayFromZero(self.props.anchorLocation.Scale - 0.5)

	if nextIndex > self.state.listSize or nextIndex < 1 then
		return currentIndex, 0
	end

	local nextDist = self:distanceToPosition(nextIndex, targetPos)
	if nextDist == 0 then
		return nextIndex, 0
	end

	return currentIndex, actualIndexPosition - targetPos
end

-- Check if trimTop is trimming the same amount multiple times.
-- If it is, there is an issue with one of the buffers which will be reported to the user.
function Scroller:checkTrimTopError(topDiff)
	if self.lastTrimTop == topDiff then
		if self.numberOfTopTrims >= REPORT_TRIMMING_ERROR_THRESHOLD then
			error("There was an error laying out the items.  Check to see if you provided enough leadBuffer and/or trailBuffer")
		else
			self.numberOfTopTrims = self.numberOfTopTrims + 1
		end
	else
		self.lastTrimTop = topDiff
		self.numberOfTopTrims = 0
	end
end

function Scroller:trimTopHelper(reverse, size, padding, anchor, topIndex, topDiff)
	local topBufferPx = reverse and self.leadBufferPx or self.trailBufferPx
	-- Ensure this trim does not set the padding to less than the topBufferPx
	if padding + topDiff < topBufferPx then
		topDiff = padding - topBufferPx
	end

	-- Make sure the topDiff will not expand canvas and that
	-- it will not trim to a negative value
	if topDiff >= 0 or size + topDiff < 0 then
		return {}
	end

	self:checkTrimTopError(topDiff)

	local trimmedCanvasSize = Round.nearest(size + topDiff)
	local trimmedPadding = Round.nearest(padding + topDiff)
	local newAnchorCanvasPosition = Round.nearest(self.anchorCanvasPosition + topDiff)
	self.log:trace("  Changing anchor canvas position from {} to {}", self.anchorCanvasPosition, newAnchorCanvasPosition)
	self.anchorCanvasPosition = newAnchorCanvasPosition

	-- Change the anchor when there is empty space at the top of the list and the anchor position has
	-- been shifted past the anchor element
	local topFramePos = self:getChildFramePosition(topIndex)
	local nextAnchorIndex = anchor.index - 1
	if nextAnchorIndex > 0 and topFramePos > 0 then
		local nextAnchorCanvasPosition = self:getChildCanvasPosition(nextAnchorIndex)
		if nextAnchorCanvasPosition > self.anchorCanvasPosition then
			local nextAnchor = {index = nextAnchorIndex, id=self:getID(nextAnchorIndex)}

			return {
				size = trimmedCanvasSize,
				padding = trimmedPadding,
				anchor = nextAnchor,
			}
		end
	end

	return {
		size = trimmedCanvasSize,
		padding = trimmedPadding,
	}
end

-- Shrink the canvas and padding so that the top of the list plus the buffer
-- is at the top of the canvas
function Scroller:trimTop(reverse, size, padding, anchor, topIndex, topCanvasPos)
	local atTop = (reverse and topIndex == self.state.listSize) or (not reverse and topIndex == 1)
	local bufferSize = reverse and self.leadBufferPx or self.trailBufferPx
	local topDiff = atTop and bufferSize - topCanvasPos or 0

	return self:trimTopHelper(reverse, size, padding, anchor, topIndex, topDiff)
end

-- Shrink the canvas and padding so that the top of the canvas is at the top of the frame
function Scroller:shortTrimTop(reverse, size, frameSize, padding, anchor, topIndex)
	local topFramePos = self:getChildFramePosition(topIndex)
	local bottomBufferPx = reverse and self.trailBufferPx or self.leadBufferPx

	-- Only trim to the top of the frame
	local topDiff
	if topFramePos >= 0 and topFramePos <= frameSize then
		topDiff = -Round.towardsZero(size - bottomBufferPx - frameSize)
	else
		topDiff = topFramePos
	end
	return self:trimTopHelper(reverse, size, padding, anchor, topIndex, topDiff)
end

-- Check if trimBottom is trimming the same amount multiple times.
-- If it is, there is an issue with one of the buffers which will be reported to the user.
function Scroller:checkTrimBottomError(bottomDiff)
	if self.lastTrimBottom == bottomDiff then
		if self.numberOfBottomTrims >= REPORT_TRIMMING_ERROR_THRESHOLD then
			error("There was an error laying out the items.  Check to see if you provided enough leadBuffer and/or trailBuffer")
		else
			self.numberOfBottomTrims = self.numberOfBottomTrims + 1
		end
	else
		self.lastTrimBottom = bottomDiff
		self.numberOfBottomTrims = 0
	end
end

function Scroller:trimBottomHelper(size, bottomDiff)
	-- Make sure the bottomDiff will not expand canvas
	if bottomDiff <= 0 then
		return {}
	end

	self:checkTrimBottomError(bottomDiff)

	local trimmedCanvasSize = Round.nearest(size - bottomDiff)

	return {
		size = trimmedCanvasSize,
	}
end

-- Shrink the canvas so that the bottom of the list plus the buffer
-- is at the bottom of the canvas
function Scroller:trimBottom(reverse, bottomIndex, bottomCanvasPos, size)
	local atBottom = (reverse and bottomIndex == 1) or (not reverse and bottomIndex == self.state.listSize)
	local bufferSize = reverse and self.trailBufferPx or self.leadBufferPx
	local bottomDiff = atBottom and (size - bufferSize) - bottomCanvasPos or 0

	-- When resizing to a larger frame size extra padding needs to be added before trimming can happen
	if self.resized and self.increasedSize then
		return {}
	end
	return self:trimBottomHelper(size, bottomDiff)
end

-- Shrink the canvas so that the bottom of the canvas is at the bottom of the frame
function Scroller:shortTrimBottom(reverse, bottomIndex, bottomCanvasPos, size, frameSize)
	local bottomFramePos = self:getChildFramePosition(bottomIndex)
	local bottomSize = self:getChildSize(bottomIndex)
	bottomFramePos = bottomFramePos + bottomSize

	if bottomFramePos >= 0 and bottomFramePos <= frameSize then
		return {}
	end

	local bufferSize = reverse and self.trailBufferPx or self.leadBufferPx
	-- Only trim to the bottom of the frame + the buffer at the end of the list
	local bottomDiff = (size - bufferSize) - bottomCanvasPos

	return self:trimBottomHelper(size, bottomDiff)
end

-- When the ends of the list are rendered, adjust the padding and canvas size so that the ends of
-- the canvas do not extend past the items in the list + the top and bottom buffers.
function Scroller:adjustEdges(newState)
	self.log:trace("adjustEdges")

	local size = newState.size or self.state.size
	size = Round.nearest(size)
	local padding = newState.padding or self.state.padding
	local anchor = newState.anchor or self.state.anchor
	local reverse = isReverse[self.props.orientation]

	local frameSize = self:measure(self:getCurrent().AbsoluteSize)
	local topIndex = reverse and self.state.lead.index or self.state.trail.index
	local topCanvasPos = Round.nearest(self:getChildCanvasPosition(topIndex)) - self.itemPadding
	local bottomIndex = reverse and self.state.trail.index or self.state.lead.index
	local childSize = self:getChildSize(bottomIndex)
	local bottomCanvasPos = Round.nearest(self:getChildCanvasPosition(bottomIndex) + childSize)

	local totalSize = self.leadBufferPx + self.trailBufferPx + (bottomCanvasPos - topCanvasPos)

	local combinedState
	if bottomCanvasPos - topCanvasPos <= frameSize or totalSize <= frameSize then
		-- For lists that are less than the size of the scrolling frame, trim the trailing edge followed by the leading edge.
		if reverse then
			local trimBottomReturnState = self:trimBottom(reverse, bottomIndex, bottomCanvasPos, size)
			local newCanvasSize = trimBottomReturnState.size or size
			local trimTopReturnState = self:shortTrimTop(reverse, newCanvasSize, frameSize, padding, anchor, topIndex)
			combinedState = Cryo.Dictionary.join(trimBottomReturnState, trimTopReturnState)
		else
			local trimTopReturnState = self:trimTop(reverse, size, padding, anchor, topIndex, topCanvasPos)
			local newCanvasSize = trimTopReturnState.size or size
			local trimBottomReturnState = self:shortTrimBottom(reverse, bottomIndex, bottomCanvasPos, newCanvasSize, frameSize)
			combinedState = Cryo.Dictionary.join(trimTopReturnState, trimBottomReturnState)
		end
	else
		-- For lists larger than the scrolling frame the order of trimming does not matter.
		local trimTopReturnState = self:trimTop(reverse, size, padding, anchor, topIndex, topCanvasPos)
		local newCanvasSize = trimTopReturnState.size or size
		local trimBottomReturnState = self:trimBottom(reverse, bottomIndex, bottomCanvasPos, newCanvasSize)
		combinedState = Cryo.Dictionary.join(trimTopReturnState, trimBottomReturnState)
	end

	if combinedState.size then
		self.log:trace("  Changing canvas size from {} to {}", size, combinedState.size)
	end
	if combinedState.padding then
		self.log:trace("  Changing canvas padding from {} to {}", padding, combinedState.padding)
	end
	if combinedState.anchor then
		self.log:trace("  Changing anchor index from {} to {}", anchor.index, combinedState.anchor.index)
	end

	return combinedState
end

-- Expand the size of the scrolling frame's canvas to make sure everything still fits.
function Scroller:expandCanvas(newState)
	self.log:trace("expandCanvas")
	local reverse = isReverse[self.props.orientation]
	local bottomIndex = reverse and self.state.trail.index or self.state.lead.index
	local topBufferPx = reverse and self.leadBufferPx or self.trailBufferPx
	local bottomBufferPx = reverse and self.trailBufferPx or self.leadBufferPx

	local size = newState.size or self.state.size
	size = Round.nearest(size)
	local originalSize = size
	local newPadding = newState.padding or self.state.padding
	local originalPadding = newPadding
	local oldPadding = self:getCurrentPadding()

	local bottomPos = self:getChildCanvasPosition(bottomIndex)
		+ self:getChildSize(bottomIndex) - (oldPadding - newPadding)

	local bottomTarget = Round.nearest(bottomPos + bottomBufferPx)

	self.log:trace("  Padding is {}", newPadding)
	self.log:trace("  Padding should be at least {}", topBufferPx)
	if newPadding < topBufferPx then
		-- Minus header
		local diff = newPadding - topBufferPx
		size = Round.nearest(size - diff)
		self.anchorCanvasPosition = Round.nearest(self.anchorCanvasPosition - diff)
		newPadding = topBufferPx
		self.log:trace("  Expanding canvas top to size {}", size)
		self.log:trace("  Shifting anchor to {}", self.anchorCanvasPosition)
		self.log:trace("  Padding is now {}", newPadding)
	end

	self.log:trace("  Bottom of bottom child is {}", bottomPos)
	self.log:trace("  Canvas size is {}", originalSize)
	self.log:trace("  Canvas bottom should be {}", bottomTarget)

	local minSize = self:measure(self:getCurrent().AbsoluteSize) - math.max(0, newPadding)
	if originalSize < minSize then
		size = minSize
		self.log:trace("  Expanding canvas to minimum size {}", size)
	end

	if originalSize < bottomTarget then
		-- Plus footer
		size = math.max(bottomTarget, size)
		self.log:trace("  Expanding canvas bottom to size {}", size)
	end

	if size ~= originalSize or newPadding ~= originalPadding then
		self.log:trace("  Changing size from {} to {}", originalSize, size)
		self.log:trace("  Changing padding from {} to {}", originalPadding, newPadding)
		return {
			size = size,
			padding = newPadding,
		}
	else
		self.log:trace("  No changes to size or padding")
		return {}
	end
end

-- Try and get the canvas as close to correct as possible this rendering pass.
function Scroller:adjustCanvas(trimTrailing, trimLeading)
	self.log:trace("adjustCanvas")

	-- if our Size prop changes, do NOT adjust, onResize() will handle this
	if self._sizePropChanged then
		self.log:trace("  Skipping because Size prop changed")
		return true
	end

	local newState = Cryo.Dictionary.join(
		self:resetAnchorPosition(),
		self:recalculateBounds(trimTrailing, trimLeading)
	)

	if not newState.trail and not newState.lead then
		newState = Cryo.Dictionary.join(newState, self:expandCanvas(newState))
	end

	if not newState.size and not newState.padding then
		newState = Cryo.Dictionary.join(newState, self:adjustEdges(newState))
	end

	if Cryo.isEmpty(newState) then
		self.log:trace("  No state changes after adjustment")
		return false
	end

	self:setState(newState)
	return true
end

function Scroller:handleResize(size)
	local reverse = isReverse[self.props.orientation]
	local canvasSize = Round.nearest(self:measure(self:getCurrent().CanvasSize).Offset)
	local frameSize = self:measure(self:getCurrent().AbsoluteSize)

	local topBufferPx = reverse and self.leadBufferPx or self.trailBufferPx
	local bottomBufferPx = reverse and self.trailBufferPx or self.leadBufferPx

	local bottomIndex = reverse and self.state.trail.index or self.state.lead.index
	local topIndex = reverse and self.state.lead.index or self.state.trail.index

	local childSize = self:getChildSize(bottomIndex)
	local topPos = Round.nearest(self:getChildCanvasPosition(topIndex)) - self.itemPadding
	local bottomPos = Round.nearest(self:getChildCanvasPosition(bottomIndex)) + childSize
	local itemSize = bottomPos + bottomBufferPx - topPos

	local frameDiff = 0
	if self.prevCycle.frameSize and size then
		frameDiff = size - self.prevCycle.frameSize
	end

	local bottomFrameCanvasPosition = self.prevCycle.canvasPosition + self.prevCycle.frameSize
	local openCanvasAtBottom = math.max(self.prevCycle.canvasSize - bottomBufferPx - bottomFrameCanvasPosition, 0)
	local openCanvasAtTop = self.prevCycle.canvasPosition

	local trimmablePadding = 0
	if frameSize < canvasSize then
		trimmablePadding = topPos - topBufferPx
	end

	local botAdjustment
	local topAdjustment

	if frameDiff < 0 then -- contracting
		if self.relativeAnchorLocation > frameSize * 0.5 then -- if we're at the bottom
			topAdjustment = math.min(trimmablePadding, frameDiff)
			botAdjustment = frameDiff - topAdjustment
		else -- at the top
			botAdjustment = frameDiff
			topAdjustment = 0
		end
	else -- expanding
		-- first fill opposite end, then spillover to same end.
		-- Any remaining space goes back to opposite end
		if self.relativeAnchorLocation > frameSize * 0.5 then
			topAdjustment = math.min(openCanvasAtTop, frameDiff)
			local frameDiffRemainder = frameDiff - topAdjustment
			botAdjustment = math.min(openCanvasAtBottom, frameDiffRemainder)
			frameDiffRemainder = frameDiffRemainder - botAdjustment
			topAdjustment = topAdjustment + frameDiffRemainder
		else
			botAdjustment = math.min(openCanvasAtBottom, frameDiff)
			local frameDiffRemainder = frameDiff - botAdjustment
			topAdjustment = math.min(openCanvasAtTop, frameDiffRemainder)
			frameDiffRemainder = frameDiffRemainder - topAdjustment
			botAdjustment = botAdjustment + frameDiffRemainder
		end
	end

	-- if bottomUp scroller
	if self.relativeAnchorLocation >= frameSize * 0.5 then

		local currentAnchorCanvasPosition =
			self:getAnchorCanvasFromIndex(self.state.anchor.index) - self.anchorFramePosition

		local newAnchor, remainder =
			self:findIndexWithRemainder(currentAnchorCanvasPosition + frameDiff - topAdjustment,
										self.state.anchor.index,
										false)

		self.anchorFramePosition = math.max(remainder, 0)
		self.anchorCanvasPosition = math.min(currentAnchorCanvasPosition + frameDiff, canvasSize - bottomBufferPx)

		if frameDiff > 0 then
			-- self.anchorOffset affects padding
			self.anchorOffset = openCanvasAtTop + self.anchorFramePosition - topAdjustment
		end

		self:setState({
			anchor = {index = newAnchor, id = self:getID(newAnchor)},
		})
	else--topDown scroller
		local newCanvasSize = canvasSize
		if canvasSize > itemSize then
			newCanvasSize = math.min(itemSize, canvasSize + botAdjustment)
		end

		local newAnchor, remainder =
			self:findIndexWithRemainder(self.anchorCanvasPosition - topAdjustment,
										self.state.anchor.index,
										false)

		-- if we expand past the amount of canvas available, move the anchor to the bottom of the first element
		if math.abs(botAdjustment) < math.abs(frameDiff) then
			self.anchorFramePosition = 0
		elseif newAnchor == self.state.anchor.index then
			self.anchorFramePosition = self.anchorFramePosition + topAdjustment
		else
			self.anchorFramePosition = self.anchorFramePosition + remainder
		end

		self.anchorCanvasPosition = self.anchorCanvasPosition - topAdjustment
		self:setState({
			size = newCanvasSize,
			anchor = { index = newAnchor, id = self:getID(newAnchor) },
		})
	end
end

-- Move the canvas position so that the anchor element is in the same place on the screen.
function Scroller:scrollToAnchor()
	if self.motorActive then
		return
	end
	self.log:trace("scrollToAnchor")
	if self.indexChanged == nil then
		self:moveToAnchor()
	end

	local newIndex = self.indexChanged.newIndex
	local previousIndex = self.indexChanged.oldIndex
	self.log:trace(" newIndex {}", newIndex)
	self.log:trace(" previousIndex {}", previousIndex)

	local oldPos = self:measure(self:getCurrent().CanvasPosition) + self.relativeAnchorLocation
	local newPos = self:getAnchorCanvasFromIndex(newIndex)

	self.log:trace(" old anchor pos {}", oldPos)
	self.log:trace(" new anchor pos {}", newPos)

	self.indexChanged.currentPos = oldPos
	self.indexChanged.newPos = newPos
	self.motorActive = true
	self.springLock = self.springLock + 1

	local delta = newPos - oldPos
	self.log:trace(" delta {}", delta)
	self.motor = Otter.createSingleMotor(0)
	self.motor:onStep(self.motorOnStep)
	self.motor:onComplete(self.motorOnComplete)
	self.motor:setGoal(Otter.spring(delta, self.props.animateOptions))
end

-- Move the canvas position so that the anchor element is in the same place on the screen.
function Scroller:moveToAnchor()
	self.log:trace("moveToAnchor")
	if self.motorActive then
		return
	end
	if self:isScrollingWithElasticBehavior() then
		return
	end

	local currentPos = self:getAnchorFramePosition()
	self.log:trace("  Anchor was at frame position {}", self.anchorFramePosition)
	self.log:trace("  Anchor is currently at frame position {}", currentPos)
	local newPos = self:measure(self:getCurrent().CanvasPosition) + currentPos - self.anchorFramePosition
	self.log:trace("  Canvas should scroll to {}", newPos)
	local current = self:getCurrent()
	local maxPos = math.max(0, self:measure(current.CanvasSize).Offset - self:measure(current.AbsoluteSize))

	self:setScroll(newPos)
	if newPos < 0 then
		self.log:trace("  Canvas scroll limited to 0, was {}", newPos)
		self.anchorOffset = Round.towardsZero(newPos)
	elseif newPos >= maxPos then
		self.log:trace("  Canvas scroll limited to {}, was {}", maxPos, newPos)
		self.anchorOffset = Round.towardsZero(newPos - maxPos)
	else
		self.log:trace("  Clearing anchorOffset")
		self.anchorOffset = 0
	end
end

-- Prevent scrolling when experiencing elastic behavior on touch devices
function Scroller:isScrollingWithElasticBehavior()
	-- When the canvas is resized the bottom of the canvas is bigger than the canvas for
	-- the first update.  Since a resize is not an elastic scroll skip these checks after a resize
	if self.resized then
		return false
	end

	-- Check if the top of the list has scrolled past the frame because of ElasticBehavior
	local reverse = isReverse[self.props.orientation]
	local topIndex = reverse and self.state.lead.index or self.state.trail.index
	local startOfListIndex = reverse and self.state.listSize or 1
	if self:measure(self:getCurrent().CanvasPosition) < 0 and topIndex == startOfListIndex then
		return true
	end

	-- Check if the bottom of the list has scrolled past the frame because of ElasticBehavior
	local bottomIndex = reverse and self.state.trail.index or self.state.lead.index
	local frameSize = self:measure(self:getCurrent().AbsoluteSize)
	local canvasPosition = self:measure(self:getCurrent().CanvasPosition)
	local endOfListIndex = reverse and 1 or self.state.listSize
	local bottomOfCanvas = Round.nearest(canvasPosition + frameSize)
	local canvasSize = Round.nearest(self:measure(self:getCurrent().CanvasSize).Offset)

	if bottomOfCanvas > canvasSize and bottomIndex == endOfListIndex and canvasPosition > 0 then
		return true
	end

	return false
end

-- Call loadNext and loadPrevious if needed.
function Scroller:loadMore()
	self.log:trace("loadMore")
	if self.props.loadPrevious and
		self.state.trail.index <= self.props.loadingBuffer and
		self.props.itemList ~= self.lastLoadPrevItems then
			self.log:trace("  Calling loadPrevious")
			self.lastLoadPrevItems = self.props.itemList
			self.props.loadPrevious()
	end
	if self.props.loadNext and
		self.state.lead.index > self.state.listSize - self.props.loadingBuffer and
		self.props.itemList ~= self.lastLoadNextItems then
			self.log:trace("  Calling loadNext")
			self.lastLoadNextItems = self.props.itemList
			self.props.loadNext()
	end
end

-- Set the current canvas position according to Orientation without calling
-- onScroll.
function Scroller:setScroll(pos)
	self.log:trace("    Scrolling to {}", pos)
	self.scrollDebounce = true
	self:getCurrent().CanvasPosition = isVertical[self.props.orientation]
		and Vector2.new(self:getCurrent().CanvasPosition.X, pos)
		or Vector2.new(pos, self:getCurrent().CanvasPosition.Y)
	self.scrollDebounce = false
end

-- Scroll by a relative amount
function Scroller:scrollRelative(amount)
	self.log:trace("  Current CanvasPosition {}", self:getCurrent().CanvasPosition)
	self.log:trace("self.motorActive {}", self.motorActive)
	self:setScroll(self:measure(self:getCurrent().CanvasPosition) + amount, true)
	self.onScroll(self:getCurrent())
end


-- Returns the signed distance from the element to the given canvas-relative
-- position, or 0 if the element overlaps it. The sign of the distance is
-- relative to the list indices. For this distance calculation, the padding
-- between elements is considered part of the current element. Returns nil if
-- the element is not currently rendered.
function Scroller:distanceToPosition(index, pos)
	local child = self:getRbx(index)
	if not child then
		return nil
	end

	local childTop = self:absoluteToCanvasPosition(self:measure(child.AbsolutePosition)) - self.itemPadding
	local childSize = self:measure(child.AbsoluteSize) + 2 * self.itemPadding

	return Round.nearest(Distance.fromPointToRangeSigned(pos, childTop, childSize) * direction[self.props.orientation])
end

-- Get the canvas-relative position of the current anchor element.
function Scroller:getAnchorCanvasPosition()
	return self:getAnchorCanvasFromIndex(self.state.anchor.index)
end

function Scroller:getAnchorCanvasFromIndex(index)
	local scale = self.props.anchorLocation.Scale
	if not isReverse[self.props.orientation] then
		scale = 1 - scale
	end

	return Round.nearest(self:getChildCanvasPosition(index) + scale * self:getChildSize(index))
end

-- Get the frame-relative position of the current anchor element.
function Scroller:getAnchorFramePosition()
	return self:getAnchorFrameFromIndex(self.state.anchor.index)
end

function Scroller:getAnchorFrameFromIndex(index)
	local scale = self.props.anchorLocation.Scale
	if not isReverse[self.props.orientation] then
		scale = 1 - scale
	end

	return Round.nearest(self:getChildFramePosition(index) + scale * self:getChildSize(index))
		- self.relativeAnchorLocation
end

-- Convert an AbsolutePosition to a position relative to the top-left corner of the canvas.
function Scroller:absoluteToCanvasPosition(position)
	local current = self:getCurrent()
	local canvas = current.CanvasPosition
	local absolute = current.AbsolutePosition
	return position + self:measure(canvas) - self:measure(absolute)
end

-- Convert an AbsolutePosition to a position relative to the top-left corner of the scrolling frame.
function Scroller:absoluteToFramePosition(position)
	local current = self:getCurrent()
	local absolute = current.AbsolutePosition
	return position - self:measure(absolute)
end

-- Convert a position relative to the frame to a position relative to the canvas.
function Scroller:frameToCanvasPosition(position)
	local current = self:getCurrent()
	local canvas = current.CanvasPosition
	return position + self:measure(canvas)
end

-- Get the canvas-relative position of the element at the specified index.
function Scroller:getChildCanvasPosition(index)
	local current = self:getRbx(index)
	return current and self:absoluteToCanvasPosition(self:measure(current.AbsolutePosition)) or 0
end

-- Get the frame-relative position of the element at the specified index.
function Scroller:getChildFramePosition(index)
	local current = self:getRbx(index)
	return current and self:absoluteToFramePosition(self:measure(current.AbsolutePosition)) or 0
end

-- Get the absolute size of the element at the specified index.
function Scroller:getChildSize(index)
	local current = self:getRbx(index)
	return current and self:measure(current.AbsoluteSize) or 0
end

-- Get the ID of an element at a specific index.
function Scroller:getID(index)
	return self.props.identifier(self.props.itemList[index])
end

-- Create or update a metadata entry for the given element. This can't use
-- self.props in willUpdate as any props it uses could be out of date.
function Scroller:updateMetadata(id, item, props)
	local meta = self.metadata[id]
	if not meta then
		meta = {}
		self.metadata[id] = meta
	end

	if not meta.name then
		local elem = props.renderItem(item, false)
		meta.class = tostring(elem.component)
		local pool = self:getKeyPool(meta.class)
		meta.name = pool:get()
	end

	if not self.refpool[meta.name] then
		self.refpool[meta.name] = Roact.createRef()
	end
	meta.ref = self.refpool[meta.name]
end

-- Clear the metadata for an element that is being unloaded.
function Scroller:clearMetadata(id)
	local meta = self.metadata[id]
	if not meta then
		return
	end

	-- Not releasing the names seems like it would be a memory leak, but this
	-- relies on the fact that the key pool does not track in use keys. Rather,
	-- the key tracks which pool it came from. So if nothing is using an
	-- unreleased key, it will be garbage collected and never reused.
	if not Cryo.List.find(self.props.recyclingDisabledFor, meta.class) then
		meta.name:release()
	end
	meta.name = nil
	meta.ref = nil
end

-- Get the key pool for the given class of elements, or create a new one if that doesn't exist yet.
function Scroller:getKeyPool(class)
	if not self.pools[class] then
		self.pools[class] = KeyPool.new(class)
	end
	return self.pools[class]
end

-- Get the metadata info for the element at the specified index.
function Scroller:getMetadata(index)
	return self.metadata[self:getID(index)]
end

-- Get the current Roblox instance from the ref stored in the metadata.
function Scroller:getRbx(index)
	local meta = self:getMetadata(index)
	return meta and meta.ref and meta.ref.current
end

-- Return X or Y depending on the orientation.
function Scroller:measure(vecOrUDim2)
	return isVertical[self.props.orientation] and vecOrUDim2.Y or vecOrUDim2.X
end

-- Get the current ScrollingFrame instance.
function Scroller:getCurrent()
	return self:getRef().current
end

function Scroller:getRef()
	-- Make sure to get the ref from props if that exists.
	return self.props[Roact.Ref] or self._ref
end

return Scroller
