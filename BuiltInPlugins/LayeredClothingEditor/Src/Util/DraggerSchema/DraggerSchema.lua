--[[
	DraggerSchema, Layered Clothing Editor Dragger Implementation

	Outline:
	-- class Selection
	-- (for convinience, doesn't have to be part of the schema, you must pass
	-- an selection object conforming to this API to the DraggerContext)
	-- A class describing what objects are currently selected and notifying the
	-- dragger framework when the selection changes. This class should expose
	-- the same API as RBX::SelectionService (Get/Set/SelectionChanged).


	-- class TransformHandlesImplementation
	-- (for convinience, doesn't have to be part of the schema, you must pass
	-- this to the MoveHandles constructor)


	-- class ExtrudeHandlesImplementation
	-- (for convinience, doesn't have to be part of the schema, you must pass
	-- this to the ExtrudeHandles constructor)


	-- function getSelectionBoxComponent(draggerContext, selectable)
	-- May return nil if you do you own hovered object rendering by making
	-- use of the Schema.setHover calls, use this if you want to have a similar
	-- pulsing hovered object highlight to the core draggers.
	-- getSelectionBoxComponent should return a kind of Roact element which
	-- has same props as an RBX::SelectionBox, but where Adornee can point at
	-- the type of selectable in your schema (which may not be an Instance).


	-- class HoverEscapeDetector
	-- A class detecting when a given hovered object changes in some way that
	-- may cause it to no longer be the hovered object thanks to reasons other
	-- than the dragger changing it.


	-- function getMouseTarget(draggerContext, mouseRay, currentSelection)
	-- Get:
	--  * the current selectable
	--  * the hit item within that selectable
	--  * the distance to the hit
	-- The selectable is the thing that will be added to the selection,
	-- and the hit item within it gives optional additional context about why
	-- the selectable was selected to other schema specific code.


	-- function setHover(draggerContext, hoverSelectable, hoverItem)
	-- Sets what the environment should treat as the currently hovered object,
	-- if the environment needs to draw the hovered object differently in some
	-- way.

	[LIKELY NOT NEEDED]
	-- function setActivePoint(draggerContext, derivedWorldState)
	-- Sets the "active point", the location which the environment should try to
	-- insert new / duplicated objects at.


	[LIKELY NOT NEEDED]
	-- function isExclusiveSelectable(draggerContext, selectable, item)
	-- When clicking on the given selectable/item, should the selection be
	-- cleared and set to exactly that item and nothing else?


	-- function dispatchClick(draggerContext, clickEvent)
	-- Decide what the dragger should do when clicking in the 3d space, given
	-- a clickEvent, which is a table: {
	--     ClickedSelectable, -- The selectable that was clicked
	--     ClickedItem, -- The item in the selectable which was clicked
	--     SelectionDidContainSelectable, -- did the old selection previously
	--         contain the Selectable that was clicked?
	--     SelectionNowContainsSelectable, -- does the new selection now
	--         contain the Selectable that was clicked?
	-- }
	-- The function should return one of the following states (as a string):
	--  * "Ready" -- Do nothing until the next click
	--  * "DragSelecting" -- Begin a rubber band select
	--  * "FreeformSelectionDrag" -- Begin dragging the current selection
	-- The dragger will then enter the state specified by the return value.

	[LIKELY NOT NEEDED]
	-- function getInnerSelectable(draggerContext, dragInfo)
	-- When a freeform drag fails to be started due to the user clicking and
	-- releasing without moving their mouse, the dragger should try to select
	-- an "inner" selectable inside of the selectable that was initially clicked
	-- for the drag. For the core draggers, this means selecting a face instance
	-- underneath the clicked part.
	-- This function returns the "inner" selectable associated with a given
	-- dragInfo return from dispatchWorldClick in the case where this happens.

	[LIKELY NOT NEEDED]
	-- class FreeformDragger
	-- .new(draggerContext, draggerToolModel, dragInfo)
	--     Begins a drag with a dragInfo that was returned from dispatchClick.
	-- :rotate(axis)
	---    Rotate the dragged parts around a given axis (T/R key hookup)
	-- :update()
	--     Update the drag with a given mouse target.
	-- :render()
	--     Optional rendering function which returns a Roact component
	--     representing any snaps / joints / other UI associated with the drag.
	-- :destroy()
	--     Finish the freeform drag.


	-- function getBoxSelectCandidates(draggerContext)
	-- Returns an array of {Center = <vector3>, Selectable = <selectable>}
	-- containing all of the candidate selectables to potentially be included,
	-- in the selection after a box select, and where each one is located.


	-- class BoundsChangedTracker
	-- Tracks changes to the position of the selected items due to factors
	-- external to the dragger. For instance, when you press Ctrl+Z, the
	-- ChangeHistoryService may move the selected items, and the dragger needs
	-- to know that this happened so that it can rerender the handles around the
	-- new location of the moved items.
	-- .new(draggerContext, onChangedHandler)
	--     When an item moves, the function onChangedHandler should be called
	--     with the item which moved.
	-- :setSelection(derivedWorldState)
	--     Set the items to track position changes for
	-- :install()
	--     Begin tracking bounds changes on the target parts
	-- :uninstall()
	--     Stop tracking bounds changes on the target parts


	-- class SelectionInfo
	-- Exposes derived aggregate information about the selection.
	-- It is returned as an object so that some of the information can be lazily
	-- calculated if desired.
	-- The returned SelectionInfo can contain whatever fields and methods you
	-- need depending on your tool implementations, however, the following are
	-- are required for the DraggerFramework code:
	-- SelectionInfo
	-- .new(draggerContext, selection)
	--     Construct a SelectionInfo for a given selection of selectables.
	-- :isEmpty()
	--     Returns true when the selection has no "interesting" items in it.
	--     When this returns true, :getBoundingBox and some other functions of
	--     the SelectionInfo will not be called.
	-- :getBoundingBox() -> (CFrame at, Vector3 offset, Vector3 size)
	--     Returns the primary "basis" of the selection which the bounding box
	--     is oriented around in `at`, as well as the offset of the center of
	--     the bounding box from that basis, and the size of the bounding box.
	--     Supporting "Use Local Space" means changing the return value of this
	--     method depending on whether the option is set.
	-- :doesContainItem(item)
	--     Returns whether a given item is part of the selection or not.
	-- :isDynamic()
	--     For optimization purposes, do fields of the SelectionInfo change
	--     every single frame? If this is hardcoded to true then you don't need
	--     to implement BoundsChangedTracker, as the bounds are assumed to be
	--     changing every frame... at the cost of significantly worse perf.


	-- function addUndoWaypoint(draggerContext, waypointName)
	-- Add an undo waypoint. A simple implementation would be to simply delegate
	-- to draggerContext:addUndoWaypoint, however if you have some Lua-side
	-- undo state then you have an opportunity to edit that state in this
]]

local nilFunc = function()
	return nil
end

local falseFunc = function()
	return false
end

local emptyFunc = function() end

local freeformDraggerStub = {
	new = emptyFunc,
	rotate = emptyFunc,
	update = emptyFunc,
	render = emptyFunc,
	destroy = emptyFunc,
}

local DraggerSchema = {
	getMouseTarget = require(script.Parent.getMouseTarget),
	Selection = require(script.Parent.Selection),
	dispatchWorldClick = require(script.Parent.dispatchWorldClick),
	SelectionInfo = require(script.Parent.SelectionInfo),
	beginBoxSelect = require(script.Parent.beginBoxSelect),
	TransformHandlesImplementation = require(script.Parent.TransformHandlesImplementation),
	ExtrudeHandlesImplementation = require(script.Parent.ExtrudeHandlesImplementation),
	setHover = require(script.Parent.setHover),
	HoverEscapeDetector = require(script.Parent.HoverEscapeDetector),
	getNextSelectables = require(script.Parent.getNextSelectables),

	-- TODO
	BoundsChangedTracker = require(script.Parent.BoundsChangedTracker),


	--NOT NEEDED
	setActivePoint = emptyFunc,
	isExclusiveSelectable = falseFunc,
	FreeformDragger = freeformDraggerStub,
	getSelectionBoxComponent = nilFunc,
	endBoxSelect = emptyFunc,

	--[[
		This function gets called at the end of dragging which isn't really useful for us
		since we need access to the store's data before it changes. Do nothing here, we'll call
		our own AddWaypoint when dragging begins instead
	]]
	addUndoWaypoint = emptyFunc,
}

return DraggerSchema