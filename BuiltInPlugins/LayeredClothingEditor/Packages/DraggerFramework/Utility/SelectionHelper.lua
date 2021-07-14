--[[
	Provides utility functions related to the selection.
]]

-- Services
local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent
local shouldDragAsFace = require(DraggerFramework.Utility.shouldDragAsFace)

local getEngineFeatureModelPivotVisual = require(DraggerFramework.Flags.getEngineFeatureModelPivotVisual)

local SelectionHelper = {}

-- Returns: Did the selection change, The new selection, A change hint
function SelectionHelper.updateSelection(selectable, oldSelection, isExclusive, shouldExtendSelection)
	local doExtendSelection = shouldExtendSelection

	if not selectable then
		if doExtendSelection then
			return false, oldSelection
		else
			local wasOldSelectionNonempty = (#oldSelection > 0)
			return wasOldSelectionNonempty, {}
		end
	end

	if doExtendSelection and not (getEngineFeatureModelPivotVisual() and isExclusive) then
		-- Add or remove from the selection when ctrl or shift is held.
		local newSelection = {}
		local added, removed = {}, {}
		local didRemoveSelectableInstance = false
		for _, item in ipairs(oldSelection) do
			if item == selectable then
				didRemoveSelectableInstance = true
			else
				table.insert(newSelection, item)
			end
		end
		if didRemoveSelectableInstance then
			table.insert(removed, selectable)
		else
			table.insert(newSelection, selectable)
			table.insert(added, selectable)
		end
		return true, newSelection, {Added = added, Removed = removed}
	else
		local index = table.find(oldSelection, selectable)
		if index and not isExclusive then
			-- The instance is already in the selection. If the active instance
			-- needs to be updated, and the instance isn't already the last item
			-- in the list, move it to the end of the selection.
			local lastIndex = #oldSelection
			if index < lastIndex then
				local newSelection = {}
				table.move(oldSelection, 1, index, 1, newSelection)
				table.move(oldSelection, index + 1, lastIndex, index, newSelection)
				newSelection[lastIndex] = selectable

				-- Remove and then add the selectable to push it to
				-- the end of the selection.
				local hint = {Added = {selectable}, Removed = {selectable}}
				return true, newSelection, hint
			end

			-- Otherwise, leave the selection alone.
			return false, oldSelection
		else
			-- The instance is not in the selection and the selection is not being
			-- extended; overwrite the old selection.
			return true, {selectable}
		end
	end
end

function SelectionHelper.updateSelectionWithMultipleSelectables(
	selectables, oldSelection, shouldXorSelection, shouldExtendSelection)

	if #selectables == 0 then
		return (shouldXorSelection or shouldExtendSelection) and oldSelection or {}
	end

	local newSelection
	if shouldXorSelection or shouldExtendSelection then
		newSelection = {}
		-- Add or remove from the selection when ctrl or shift is held.
		local alreadySelectedInstances = {}
		for _, instance in ipairs(oldSelection) do
			alreadySelectedInstances[instance] = true
		end

		if shouldXorSelection then
			local newInstancesToSelect = {}
			for _, instance in ipairs(selectables) do
				newInstancesToSelect[instance] = true
			end
			for _, selectable in ipairs(oldSelection) do
				if not newInstancesToSelect[selectable] then
					table.insert(newSelection, selectable)
				end
			end
			for _, selectable in ipairs(selectables) do
				if not alreadySelectedInstances[selectable] then
					table.insert(newSelection, selectable)
				end
			end
		elseif shouldExtendSelection then
			for _, selectable in ipairs(oldSelection) do
				table.insert(newSelection, selectable)
			end
			for _, selectable in ipairs(selectables) do
				if not alreadySelectedInstances[selectable] then
					table.insert(newSelection, selectable)
				end
			end
		end
	else
		-- The selection is not being extended; overwrite the old selection.
		newSelection = selectables
	end
	return newSelection
end

return SelectionHelper
