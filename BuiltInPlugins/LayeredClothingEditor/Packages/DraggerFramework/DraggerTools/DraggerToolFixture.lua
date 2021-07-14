--[[
	DraggerToolFixture is a class containing a DraggerToolModel which is to be
	driven with syntheic inputs in order to perform testing.
]]

local DraggerFramework = script.Parent.Parent

local DraggerToolModel = require(DraggerFramework.Implementation.DraggerToolModel)

local DraggerToolFixture = {}
DraggerToolFixture.__index = DraggerToolFixture

function DraggerToolFixture.new(draggerContext, draggerSchema, draggerSettings)
	draggerSettings = draggerSettings or {}

	local self = setmetatable({
		_draggerContext = draggerContext,
		_viewBoundsDirty = true,
		_selectionBoundsDirty = true,
	}, DraggerToolFixture)

	self._draggerToolModel =
		DraggerToolModel.new(
			draggerContext,
			draggerSchema,
			draggerSettings,
			function() end,
			function() self._viewBoundsDirty = true end,
			function() self._selectionBoundsDirty = true end)

	return self
end

function DraggerToolFixture:getModel()
	return self._draggerToolModel
end

function DraggerToolFixture:_update()
	if self._selectionBoundsDirty then
		self._selectionBoundsDirty = false
		self._draggerToolModel:_processSelectionChanged()
	end
	if self._viewBoundsDirty then
		self._viewBoundsDirty = false
		self._draggerToolModel:_processViewChanged()
	end
end

function DraggerToolFixture:select()
	assert(not self._selected, "select called while already selected")
	self._selected = true
	self._draggerToolModel:_processSelected()
	self:_update()
end

function DraggerToolFixture:mouseDown()
	assert(self._selected, "must call select before beginDrag")
	self._draggerToolModel:_processMouseDown()
	self:_update()
end

function DraggerToolFixture:mouseMove(mouseX, mouseY)
	assert(self._selected, "must call select before moveMouse")
	local viewportSize = self._draggerContext:getViewportSize()
	self._draggerContext:setMouseLocation(
		Vector2.new(viewportSize.X * mouseX, viewportSize.Y * mouseY))
	self._draggerToolModel:_processViewChanged()
	self:_update()
end

function DraggerToolFixture:mouseUp()
	assert(self._selected, "must call select before endDrag")
	self._draggerToolModel:_processMouseUp()
	self:_update()
end

function DraggerToolFixture:keyPress(key)
	assert(typeof(key) == "EnumItem", "keyPress takes an Enum.KeyCode")
	assert(self._selected, "must call select before keyPress")
	self._draggerToolModel:_processKeyDown(key)
	self:_update()
	self._draggerToolModel:_processKeyUp(key)
	self:_update()
end

function DraggerToolFixture:deselect()
	assert(self._selected, "deselect called while not selected")
	self._selected = false
	self._draggerToolModel:_processDeselected()
	self:_update()
end

return DraggerToolFixture