local function newSymbol(name)
	local symbol = newproxy(true)
	name = ("Mocks.%s"):format(name)
	getmetatable(symbol).__tostring = function()
		return name
	end
	return symbol
end

return {
	Calls = newSymbol("Calls"),
	Children = newSymbol("Children"),
	Lock = newSymbol("Lock"),
	None = newSymbol("None"),
	ReturnValue = newSymbol("ReturnValue"),
}
