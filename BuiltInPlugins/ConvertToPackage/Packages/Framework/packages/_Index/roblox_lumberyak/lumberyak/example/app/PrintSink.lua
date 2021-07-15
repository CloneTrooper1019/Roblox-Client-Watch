local Logger = require(script.Parent.Parent.Parent.Logger)

local PrintSink = {}

function PrintSink.new(level)
	local printer = {
		maxLevel = level
	}

	setmetatable(printer, PrintSink)
	return printer
end

function PrintSink:log(message, context)
	if context.level == Logger.Levels.Error then
		error(message, 5)
	elseif context.level == Logger.Levels.Warning then
		warn(message)
	else
		print(message)
	end
end

return PrintSink
