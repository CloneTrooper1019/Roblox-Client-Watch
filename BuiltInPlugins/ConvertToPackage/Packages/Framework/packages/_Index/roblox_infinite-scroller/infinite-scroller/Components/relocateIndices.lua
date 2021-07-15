local Round = require(script.Parent.Round)

export type Indices = {
	anchorIndex: number?,
	leadIndex: number?,
	trailIndex: number?,
}

-- Returns the three new indices with any nils filled in and any misorderings corrected.
-- new and old should be tables containing an anchorIndex, a leadIndex and a trailIndex.
return function(new: Indices, old: Indices, listSize: number): Indices
	local isNewAnchorPresent: boolean = new.anchorIndex ~= nil
	local isNewLeadPresent: boolean = new.leadIndex ~= nil
	local isNewTrailPresent: boolean = new.trailIndex ~= nil

	local finalAnchorIndex: number = tonumber(new.anchorIndex or 0)
	local finalLeadIndex: number = tonumber(new.leadIndex or 0)
	local finalTrailIndex: number = tonumber(new.trailIndex or 0)

	local oldAnchorIndex: number = tonumber(old.anchorIndex or 0)
	local oldLeadIndex: number = tonumber(old.leadIndex or 0)
	local oldTrailIndex: number = tonumber(old.trailIndex or 0)

	-- There are 8 possibilities here as any combination of these could be deleted. Also, we can't use findIndexAt
	-- here since that requires access to the children's measurements.
	if not isNewAnchorPresent then
		if isNewLeadPresent and isNewTrailPresent then
			-- Estimate that the new anchor is proportionally the same distance from the lead and trail indices.
			if finalLeadIndex == finalTrailIndex then
				-- Guard against divide by zero.
				finalAnchorIndex = finalLeadIndex
			else
				local oldRatio = (oldAnchorIndex - oldLeadIndex) / (oldTrailIndex - oldLeadIndex)
				finalAnchorIndex = Round.nearest((finalTrailIndex - finalLeadIndex) * oldRatio + finalLeadIndex)
				finalAnchorIndex = math.min(math.max(finalAnchorIndex, 1), listSize)
			end
		elseif isNewLeadPresent then
			-- Given only the new leading index, estimate that the new anchor is the same distance away as it was.
			finalAnchorIndex = finalLeadIndex + oldAnchorIndex - oldLeadIndex
			finalAnchorIndex = math.min(math.max(finalAnchorIndex, 1), listSize)
		elseif isNewTrailPresent then
			-- Given only the new trailing index, estimate that the new anchor is the same distance away as it was.
			finalAnchorIndex = finalTrailIndex + oldAnchorIndex - oldTrailIndex
			finalAnchorIndex = math.min(math.max(finalAnchorIndex, 1), listSize)
		else
			-- Everything is gone. Just reuse the same index if that's still within the bounds of the list.
			finalAnchorIndex = math.min(math.max(oldAnchorIndex, 1), listSize)
		end
	end

	-- If the leading and trailing indices haven't been worked out yet, estimate that the new ones should be the
	-- same distance from the anchor as the old ones were.
	if not isNewTrailPresent then
		finalTrailIndex = finalAnchorIndex + oldTrailIndex - oldAnchorIndex
		finalTrailIndex = math.min(math.max(finalTrailIndex, 1), listSize)
	end
	if not isNewLeadPresent then
		finalLeadIndex = finalAnchorIndex + oldLeadIndex - oldAnchorIndex
		finalLeadIndex = math.min(math.max(finalLeadIndex, 1), listSize)
	end

	-- Make sure the resulting indices are in the right order.
	local minIndex = math.min(finalAnchorIndex, finalLeadIndex, finalTrailIndex)
	local maxIndex = math.max(finalAnchorIndex, finalLeadIndex, finalTrailIndex)

	return {
		trailIndex = minIndex,
		anchorIndex = finalAnchorIndex,
		leadIndex = maxIndex,
	}
end
