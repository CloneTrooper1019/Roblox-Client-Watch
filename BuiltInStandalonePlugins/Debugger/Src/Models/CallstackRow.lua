export type CallstackRow = {
	arrowColumn: table,
	frameColumn: string,
	whatColumn: string,
	functionNameColumn: string,
	lineNumberColumn: string,
	sourceColumn: string,
}

local ICON_SIZE = UDim2.new(0, 14, 0, 14) -- TODO: Shift to MakeTheme.lua
local ICON_PATH = "rbxasset://textures/Debugger/debugger_arrow.png" -- TODO: Shift to MakeTheme.lua

local function new() : CallstackRow
	return {
		arrowColumn = {},
		frameColumn = "",
		whatColumn = "",
		functionNameColumn = "",
		lineNumberColumn = "",
		sourceColumn = "",
	}
end

local function fromData(data) : CallstackRow
	return {
		arrowColumn = data.arrowColumn,
		frameColumn = data.frameColumn,
		whatColumn = data.whatColumn,
		functionNameColumn = data.functionNameColumn,
		lineNumberColumn = data.lineNumberColumn,
		sourceColumn = data.sourceColumn,
	}
end

return {
	new = new,
	fromData = fromData,
	ICON_SIZE = ICON_SIZE,
	ICON_PATH = ICON_PATH, 
}
