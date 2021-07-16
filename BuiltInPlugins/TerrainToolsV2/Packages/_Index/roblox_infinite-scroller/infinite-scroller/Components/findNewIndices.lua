-- Find the new indicies of the trailing, anchor and leading elements.
-- props is expected to contain itemList, the identifier function and the maximum search distance.
-- state is expected to contain the old top, anchor and bottom indices and ids.
return function(props, state): (number?, number?, number?)
	local topIndex = state.trail.index
	local topID = state.trail.id
	local anchorIndex = state.anchor.index
	local anchorID = state.anchor.id
	local bottomIndex = state.lead.index
	local bottomID = state.lead.id

	local listSize = #props.itemList

	-- If too much got deleted and the previous anchor index is off the bottom of the list, start the search from
	-- the bottom.
	if topIndex > listSize then
		topIndex = listSize
	end
	if anchorIndex > listSize then
		anchorIndex = listSize
	end
	if bottomIndex > listSize then
		bottomIndex = listSize
	end

	-- No access to self:getID
	local getID = function(index): string
		return props.identifier(props.itemList[index])
	end
	local topStill = getID(topIndex) == topID
	local anchorStill = getID(anchorIndex) == anchorID
	local bottomStill = getID(bottomIndex) == bottomID
	if topStill and anchorStill and bottomStill then
		-- Nothing important moved
		return topIndex, anchorIndex, bottomIndex
	end

	local step = 0
	local foundTop = topStill and topIndex or nil
	local foundAnchor = nil
	local foundBottom = bottomStill and bottomIndex or nil

	-- Scan outward from the old anchor index until we find the top and bottom or hit the max distance
	local deltas = {top=-1, bottom=1}
	repeat
		for _, delta: number in pairs(deltas) do
			local pos = anchorIndex + delta * step

			if pos >= 1 and pos <= listSize then
				local id = getID(pos)
				if id == topID then
					foundTop = pos
				end
				if id == anchorID then
					foundAnchor = pos
				end
				if id == bottomID then
					foundBottom = pos
				end
			end
		end

		step = step + 1
	until (foundTop and foundAnchor and foundBottom) or step > props.maximumSearchDistance

	return foundTop, foundAnchor, foundBottom
end
