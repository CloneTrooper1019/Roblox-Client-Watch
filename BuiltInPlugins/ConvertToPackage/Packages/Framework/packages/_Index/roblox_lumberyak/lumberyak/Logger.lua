local Root = script.Parent.Parent
local Cryo = require(Root.Cryo)

local Logger = {}
Logger.__index = Logger

Logger.Levels = {
	Error = "Error",
	Warning = "Warning",
	Info = "Info",
	Debug = "Debug",
	Trace = "Trace",
}

local levelOrder = {
	Logger.Levels.Error,
	Logger.Levels.Warning,
	Logger.Levels.Info,
	Logger.Levels.Debug,
	Logger.Levels.Trace,
}

local levelRank = {}
for k, v in pairs(levelOrder) do
	levelRank[v] = k
end

function Logger.Levels.fromString(str)
	if type(str) ~= "string" then
		return nil
	end
	for _, k in pairs(levelOrder) do
		if string.lower(k) == string.lower(str) then
			return k
		end
	end
	return nil
end

function Logger.new(parent, name)
	local logger = {
		name = name,
		sinks = {},
		children = {},
		parent = parent,
		context = {},
		dirty = true,
		active = {},
		cache = {
			sinks = {},
			context = {},
		}
	}

	for k, _ in pairs(Logger.Levels) do
		if parent then
			logger.active[k] = parent.active[k]
		else
			logger.active[k] = false
		end
	end

	if parent then
		parent.children[logger] = true
	end

	setmetatable(logger, Logger)
	return logger
end

-- Activate `level` and above logging levels.
local function setActive(level, node)
	local maxLevel = levelRank[level]
	if maxLevel then
		for n = 1,maxLevel do
			node.active[levelOrder[n]] = true
		end
		for k, _ in pairs(node.children) do
			setActive(level, k)
		end
	end
end

-- Set the dirty flag for `node` and all its children.
local function setDirty(node)
	node.dirty = true
	for k, _ in pairs(node.children) do
		setDirty(k)
	end
end

-- Update the context and sinks cache for `node` and its ancestors.
local function updateCache(node)
	if not node.dirty then
		return
	end

	if not node.parent then
		node.cache.context = node.context
		node.cache.sinks = node.sinks
		node.dirty = false
		return
	end

	updateCache(node.parent)

	-- Dictionary join the context. List join the sinks. Concatenate the prefixes.
	node.cache.context = Cryo.Dictionary.join(node.parent.cache.context, node.context)
	if node.parent.cache.context.prefix and node.context.prefix then
		node.cache.context.prefix = node.parent.cache.context.prefix .. node.context.prefix
	end
	node.cache.sinks = Cryo.List.join(node.parent.cache.sinks, node.sinks)
	node.dirty = false
end

-- Set the parent of this Logger and update its cache, active bits and dirty bit.
function Logger:setParent(parent)
	if self.parent then
		self.parent.children[self] = nil
	end

	updateCache(parent)
	self.parent = parent
	self.parent.children[self] = true

	local maxLevel = -1
	for _, sink in pairs(parent.cache.sinks) do
		local sinkLevel = levelRank[sink.maxLevel]
		if sinkLevel then
			maxLevel = math.max(maxLevel, levelRank[sink.maxLevel])
		end
	end

	if maxLevel > -1 then
		setActive(levelOrder[maxLevel], self)
	end

	setDirty(self)
end

function Logger:addSink(sink)
	setActive(sink.maxLevel, self)
	table.insert(self.sinks, sink)
	setDirty(self)
end

function Logger:setContext(context)
	self.context = context
	setDirty(self)
end

local function log(level, node, args)
	if node.dirty then
		updateCache(node)
	end

	-- Collect per-log context.
	local fullContext = {
		level = level,
		rawMessage = args,
		loggerName = node.name,
	}

	-- Call any functions in the context.
	for k, v in pairs(node.cache.context) do
		if type(v) == "function" then
			fullContext[k] = v()
		else
			fullContext[k] = v
		end
	end

	-- Interpolate the log message.
	local interpMsg
	if args.n == 0 then
		interpMsg = "LUMBERYAK INTERNAL: No log message given"
	else
		interpMsg = args[1]
	end
	if fullContext.prefix then
		interpMsg = fullContext.prefix .. interpMsg
	end

	if interpMsg:find("{") then
		local i = 1
		interpMsg = (interpMsg:gsub("{(.-)}", function(w)
			-- Treat {} as a positional arg.
			if w == "" then
				i = i + 1
				return tostring(args[i])
			end
			local c = fullContext[w]
			return c and tostring(c)
		end))
		if i < args.n then
			interpMsg = interpMsg .. "\nLUMBERYAK INTERNAL: Too many arguments given for format string"
		elseif i > args.n then
			interpMsg = interpMsg .. "\nLUMBERYAK INTERNAL: Too few arguments given for format string"
		end
	elseif args.n > 1 then
		interpMsg = interpMsg .. "\nLUMBERYAK INTERNAL: Too many arguments given for format string"
	end

	-- Send the message to any sinks that are listening to the right level.
	local rank = levelRank[level]
	for _, k in pairs(node.cache.sinks) do
		if levelRank[k.maxLevel] and levelRank[k.maxLevel] >= rank then
			k:log(interpMsg, fullContext)
		end
	end
end

function Logger:error(...)
	if not self.active[Logger.Levels.Error] then
		return
	end
	log(Logger.Levels.Error, self, table.pack(...))
end

function Logger:warning(...)
	if not self.active[Logger.Levels.Warning] then
		return
	end
	log(Logger.Levels.Warning, self, table.pack(...))
end

function Logger:info(...)
	if not self.active[Logger.Levels.Info] then
		return
	end
	log(Logger.Levels.Info, self, table.pack(...))
end

function Logger:debug(...)
	if not self.active[Logger.Levels.Debug] then
		return
	end
	log(Logger.Levels.Debug, self, table.pack(...))
end

function Logger:trace(...)
	if not self.active[Logger.Levels.Trace] then
		return
	end
	log(Logger.Levels.Trace, self, table.pack(...))
end

return Logger
