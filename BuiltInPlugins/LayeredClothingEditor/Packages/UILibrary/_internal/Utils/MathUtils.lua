local MathUtils = {}

MathUtils.NEAR_ZERO = 0.0001

function MathUtils:fuzzyEq(numOne, numTwo, epsilon)
	epsilon = epsilon or MathUtils.NEAR_ZERO
	return math.abs(numOne - numTwo) < epsilon
end

function MathUtils:round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

return MathUtils