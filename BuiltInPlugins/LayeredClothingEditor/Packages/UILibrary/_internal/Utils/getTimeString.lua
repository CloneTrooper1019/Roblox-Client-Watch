-- DEPRECATED - use formatDuration from DeveloperFramework
-- return mm:ss format.
return function(seconds)
	assert(type(seconds) == "number", "seconds must be a number")

	local isNegative = seconds < 0
	local adjustedSeconds = math.abs(seconds)
	local min = math.floor(adjustedSeconds / 60)
	local sec = math.floor(adjustedSeconds % 60)

	return string.format("%s%d:%02d", isNegative and "-" or "", min, sec)
end