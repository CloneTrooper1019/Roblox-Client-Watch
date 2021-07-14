return function()

	local FORMAT_STRING = "YYYY/MM/DD LTS"

	-- Using en-gb locale as its local time format (LTS) does not include the meridiem, simplifying the tests
	local LOCALE = "en-gb"

	-- These two values correspond
	local ISO_DATE_STRING = "2020-09-09T13:00:00Z"
	-- local ISO_DATE_STRING = "2020-09-09T00:00:00Z"
	local UNIX_TIME = 1599656400

	local formatLocalDateTime = require(script.Parent.formatLocalDateTime)

	it("throws if not all arguments are passed", function()
		expect(function()
			formatLocalDateTime()
		end).to.throw()

		expect(function()
			formatLocalDateTime(ISO_DATE_STRING)
		end).to.throw()

		expect(function()
			formatLocalDateTime(ISO_DATE_STRING, FORMAT_STRING)
		end).to.throw()
	end)

	it("returns original string if passed a date string which is not valid ISO8601", function()
		local nonIsoDateString = "September 9th 2020"
		expect(formatLocalDateTime(nonIsoDateString, FORMAT_STRING, LOCALE)).to.equal(nonIsoDateString)
	end)

	-- TODO STM-369: This test does not work in CLI - the locale information does not appear to be available
	-- so formatLocalDateTime falls back to returning the ISO input string
	itSKIP("formats UTC date string", function()
		-- We can't set the current timezone as used by this function,
		-- so we calculate what we expect the result to be dynamically
		-- as this will vary based on the machine running the test.
		local components = os.date("*t", UNIX_TIME)

		-- E.g. 2020/12/01 12:00:00
		local expected = string.format("%04d", components.year) .. "/" ..
			string.format("%02d", components.month) .. "/" ..
			string.format("%02d", components.day) .. " " ..
			string.format("%02d", components.hour) .. ":" ..
			string.format("%02d", components.min) .. ":" ..
			string.format("%02d", components.sec)

		expect(formatLocalDateTime(ISO_DATE_STRING, FORMAT_STRING, LOCALE)).to.equal(expected)
	end)
end