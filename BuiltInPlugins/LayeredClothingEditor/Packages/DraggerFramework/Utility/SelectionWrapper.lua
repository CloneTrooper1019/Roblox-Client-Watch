--[[
	A wrapper around a Selection object (anything with the same API the Roblox
	SelectionService has), which disambiguates selection changed events which
	were caused by something else setting the selection, vs selection changed
	events which were caused by calling :Set on the Selection object.

	Also caches the selection between changes, so that repeated calls to
	the get method do not need to check what the underlying selection is.
]]

local DraggerFramework = script.Parent.Parent
local Signal = require(DraggerFramework.Utility.Signal)

local SelectionWrapper = {}
SelectionWrapper.__index = SelectionWrapper

local WRAPPER_COUNT = 0

function SelectionWrapper.new(selectionObject)
	local self = setmetatable({
		_selectionObject = selectionObject,
		_selection = selectionObject:Get(),
		_isSettingSelection = false,
		_destroyed = false,
	}, SelectionWrapper)

	self.onSelectionExternallyChanged = Signal.new()
	self._selectionChangedConnection =
		selectionObject.SelectionChanged:Connect(function()
			self:_handleSelectionChanged()
		end)

	WRAPPER_COUNT = WRAPPER_COUNT + 1
	if WRAPPER_COUNT > 1 then
		warn("More than one SelectionWrapper created at once, this is probably a mistake!")
	end

	return self
end

function SelectionWrapper:get()
	return self._selection
end

function SelectionWrapper:set(selection, hint)
	self._selection = selection
	self._isSettingSelection = true
	self._selectionObject:Set(selection, hint)
	self._isSettingSelection = false
end

function SelectionWrapper:destroy()
	assert(not self._destroyed)
	self._selectionChangedConnection:Disconnect()
	WRAPPER_COUNT = WRAPPER_COUNT - 1
	self._destroyed = true
end

function SelectionWrapper:_handleSelectionChanged()
	if not self._isSettingSelection then
		self._selection = self._selectionObject:Get()
		self.onSelectionExternallyChanged:Fire()
	end
end

function SelectionWrapper:getActiveSelectable()
	return self._selection[#self._selection]
end

return SelectionWrapper