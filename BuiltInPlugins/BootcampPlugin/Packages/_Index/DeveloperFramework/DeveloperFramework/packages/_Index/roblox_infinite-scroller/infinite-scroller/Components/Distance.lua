return {
	-- Returns the signed distance from a point to a range. Returns 0 if the
	-- point is within the range, positive if it's below and negative if it's
	-- above.
	fromPointToRangeSigned = function(point: number, rangeTop: number, rangeSize: number)
		local rangeBottom = rangeTop + rangeSize

		if point < rangeTop then
			return point - rangeTop
		elseif point > rangeBottom then
			return point - rangeBottom
		else
			return 0
		end
	end
}
