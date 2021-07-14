local Framework = script.Parent.Parent.Parent
local t = require(Framework.Util.Typecheck.t)


local IBacktraceStack = t.strictInterface({
	guessed_frame = t.optional(t.boolean),
	funcName = t.optional(t.string),
	address = t.optional(t.string),
	line = t.optional(t.string),
	column = t.optional(t.string),
	sourceCode = t.optional(t.string),
	library = t.optional(t.string),
	debug_identifier = t.optional(t.string),
	faulted = t.optional(t.boolean),
	registers = t.optional(t.map(t.string, t.some(t.string, t.number))),
})

local IBacktraceThread = t.strictInterface({
	name = t.optional(t.string),
	fault = t.optional(t.boolean),
	stack = t.optional(t.array(IBacktraceStack)),
})

local IArch = t.strictInterface({
	name = t.string,
	registers = t.map(t.string, t.string),
})

local ISourceCode = t.strictInterface({
	text = t.optional(t.string),
	startLine = t.optional(t.number),
	startColumn = t.optional(t.number),
	startPos = t.optional(t.number),
	path = t.optional(t.string),
	tabWidth = t.optional(t.number),
})

local IPerm = t.strictInterface({
	read = t.boolean,
	write = t.boolean,
	exec = t.boolean,
})

local IMemory = t.strictInterface({
	start = t.string,
	size = t.optional(t.number),
	data = t.optional(t.string),
	perms = t.optional(IPerm),
})

local IModule = t.strictInterface({
	start = t.string,
	size = t.number,
	code_file = t.optional(t.string),
	version = t.optional(t.string),
	debug_file = t.optional(t.string),
	debug_identifier = t.optional(t.string),
	debug_file_exists = t.optional(t.boolean),
})

local IAttributes = t.optional(t.map(t.string, t.some(t.string, t.number, t.boolean)))

local IAnnotation = function(annotation)
	local function checkTypeRecursive(value)
		if type(value) == "table" then
			for key, subValue in pairs(value) do
				local valid, error = checkTypeRecursive(subValue)
				if not valid then
					return false, string.format("error when checking key: %s - %s", key, error)
				end
			end
			return true
		else
			local isAcceptedType = t.some(t.string, t.number, t.boolean)
			return isAcceptedType(value)
		end
	end

	return checkTypeRecursive(annotation)
end

local IAnnotations = t.optional(t.map(t.string, IAnnotation))

local IBacktraceReport = t.intersection(
	t.strictInterface({
		-- Must haves
		uuid = t.string,
		timestamp = t.number,
		lang = t.string,
		langVersion = t.string,
		agent = t.string,
		agentVersion = t.string,
		threads = t.map(t.string, IBacktraceThread),
		mainThread = t.string,

		-- Optionals
		attributes = IAttributes,
		annotations = IAnnotations,
		symbolication = t.optional(t.literal("minidump")),
		entryThread = t.optional(t.string),
		arch = t.optional(IArch),
		fingerprint = t.optional(t.string),
		classifiers = t.optional(t.array(t.string)),
		sourceCode = t.optional(t.map(t.string, ISourceCode)),
		memory = t.optional(t.array(IMemory)),
		modules = t.optional(t.array(IModule)),
	}),
	function(report)
		local hasRegisters = false

		local threads = report.threads
		for _, thread in pairs(threads) do
			local stacks = thread.stack
			if stacks ~= nil then
				for _, stack in ipairs(stacks) do
					if stack.registers ~= nil then
						hasRegisters = true
						break
					end
				end
			end
			if hasRegisters then
				break
			end
		end

		if hasRegisters and report.arch == nil then
			return false, "arch must exist if you want to have registers in the stack"
		else
			return true
		end
	end
)

local IBacktraceReporter = t.strictInterface({
	networking = t.interface({
		request = t.callback,
		post = t.callback,
	}),
	accessToken = t.string,
	processErrorReportMethod = t.optional(t.callback),
	queueOptions = t.optional(t.strictInterface({
		queueTimeLimit = t.optional(t.numberPositive),
		queueErrorLimit = t.optional(t.numberPositive),
		queueKeyLimit = t.optional(t.numberPositive),
	})),
	generateLogMethod = t.optional(t.callback),
	logIntervalInSeconds = t.optional(t.numberPositive),
})

return {
	IBacktraceStack = IBacktraceStack,
	IBacktraceThread = IBacktraceThread,
	IArch = IArch,
	ISourceCode = ISourceCode,
	IPerm = IPerm,
	IMemory = IMemory,
	IModule = IModule,
	IAttributes = IAttributes,
	IAnnotation = IAnnotation,
	IAnnotations = IAnnotations,
	IBacktraceReport = IBacktraceReport,
	IBacktraceReporter = IBacktraceReporter,
}