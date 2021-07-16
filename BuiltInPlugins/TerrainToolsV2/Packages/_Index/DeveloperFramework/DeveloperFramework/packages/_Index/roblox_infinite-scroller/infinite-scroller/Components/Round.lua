local epsilon = 1e-15

return {
	nearest = function(num)
		local q, r = math.modf(num)
		if r <= -0.5 then
			return q - 1
		elseif r >= 0.5 then
			return q + 1
		else
			return q
		end
	end,
	towardsZero = function(num)
		local result, _ = math.modf(num)
		return result
	end,
	awayFromZero = function(num)
		local q, r = math.modf(num)
		if r < -epsilon then
			return q - 1
		elseif r > epsilon then
			return q + 1
		else
			return q
		end
	end,
}