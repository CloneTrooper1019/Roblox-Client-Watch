local function formatLocalDateTme(isoDateTimeString, formatString, localeId)
	assert(type(isoDateTimeString) == "string", "must pass an isoDateTimeString")
	assert(type(formatString) == "string", "must pass a formatString")
	assert(type(localeId) == "string", "must pass a localeId")
	local dateTime = DateTime.fromIsoDate(isoDateTimeString)

	if dateTime == nil then
		return isoDateTimeString
	else
		return dateTime:FormatLocalTime(formatString, localeId)
	end
end

return formatLocalDateTme