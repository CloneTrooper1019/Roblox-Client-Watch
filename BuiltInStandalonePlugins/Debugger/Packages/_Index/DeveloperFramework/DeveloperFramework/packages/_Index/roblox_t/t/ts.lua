-- t: a runtime typechecker for Roblox

-- regular lua compatibility
local typeof = typeof or type

local function primitive(typeName)
	return function(value)
		local valueType = typeof(value)
		if valueType == typeName then
			return true
		else
			return false
		end
	end
end

local t = {}

function t.any(value)
	if value ~= nil then
		return true
	else
		return false
	end
end

--Lua primitives

t.boolean = primitive("boolean")
t.thread = primitive("thread")
t.callback = primitive("function")
t.none = primitive("nil")
t.string = primitive("string")
t.table = primitive("table")
t.userdata = primitive("userdata")

function t.number(value)
	local valueType = typeof(value)
	if valueType == "number" then
		if value == value then
			return true
		else
			return false
		end
	else
		return false
	end
end

function t.nan(value)
	if value ~= value then
		return true
	else
		return false
	end
end

-- roblox types

t.Axes = primitive("Axes")
t.BrickColor = primitive("BrickColor")
t.CFrame = primitive("CFrame")
t.Color3 = primitive("Color3")
t.ColorSequence = primitive("ColorSequence")
t.ColorSequenceKeypoint = primitive("ColorSequenceKeypoint")
t.DockWidgetPluginGuiInfo = primitive("DockWidgetPluginGuiInfo")
t.Faces = primitive("Faces")
t.Instance = primitive("Instance")
t.NumberRange = primitive("NumberRange")
t.NumberSequence = primitive("NumberSequence")
t.NumberSequenceKeypoint = primitive("NumberSequenceKeypoint")
t.PathWaypoint = primitive("PathWaypoint")
t.PhysicalProperties = primitive("PhysicalProperties")
t.Random = primitive("Random")
t.Ray = primitive("Ray")
t.Rect = primitive("Rect")
t.Region3 = primitive("Region3")
t.Region3int16 = primitive("Region3int16")
t.TweenInfo = primitive("TweenInfo")
t.UDim = primitive("UDim")
t.UDim2 = primitive("UDim2")
t.Vector2 = primitive("Vector2")
t.Vector3 = primitive("Vector3")
t.Vector3int16 = primitive("Vector3int16")
t.Enum = primitive("Enum")
t.EnumItem = primitive("EnumItem")
t.RBXScriptSignal = primitive("RBXScriptSignal")
t.RBXScriptConnection = primitive("RBXScriptConnection")

function t.literal(...)
	local size = select("#", ...)
	if size == 1 then
		local literal = ...
		return function(value)
			if value ~= literal then
				return false
			end
			return true
		end
	else
		local literals = {}
		for i = 1, size do
			local value = select(i, ...)
			literals[i] = t.literal(value)
		end
		return t.union(unpack(literals))
	end
end

t.exactly = t.literal

function t.keyOf(keyTable)
	local keys = {}
	for key in pairs(keyTable) do
		keys[#keys + 1] = key
	end
	return t.literal(unpack(keys))
end

function t.valueOf(valueTable)
	local values = {}
	for _, value in pairs(valueTable) do
		values[#values + 1] = value
	end
	return t.literal(unpack(values))
end

function t.integer(value)
	local success = t.number(value)
	if not success then
		return false
	end
	if value%1 == 0 then
		return true
	else
		return false
	end
end

function t.numberMin(min)
	return function(value)
		local success = t.number(value)
		if not success then
			return false
		end
		if value >= min then
			return true
		else
			return false
		end
	end
end

function t.numberMax(max)
	return function(value)
		local success = t.number(value)
		if not success then
			return false
		end
		if value <= max then
			return true
		else
			return false
		end
	end
end

function t.numberMinExclusive(min)
	return function(value)
		local success = t.number(value)
		if not success then
			return false
		end
		if min < value then
			return true
		else
			return false
		end
	end
end

function t.numberMaxExclusive(max)
	return function(value)
		local success = t.number(value)
		if not success then
			return false
		end
		if value < max then
			return true
		else
			return false
		end
	end
end

t.numberPositive = t.numberMinExclusive(0)
t.numberNegative = t.numberMaxExclusive(0)

function t.numberConstrained(min, max)
	assert(t.number(min) and t.number(max))
	local minCheck = t.numberMin(min)
	local maxCheck = t.numberMax(max)
	return function(value)
		local minSuccess = minCheck(value)
		if not minSuccess then
			return false
		end

		local maxSuccess = maxCheck(value)
		if not maxSuccess then
			return false
		end

		return true
	end
end

function t.numberConstrainedExclusive(min, max)
	assert(t.number(min) and t.number(max))
	local minCheck = t.numberMinExclusive(min)
	local maxCheck = t.numberMaxExclusive(max)
	return function(value)
		local minSuccess = minCheck(value)
		if not minSuccess then
			return false
		end

		local maxSuccess = maxCheck(value)
		if not maxSuccess then
			return false
		end

		return true
	end
end

function t.match(pattern)
	assert(t.string(pattern))
	return function(value)
		local stringSuccess = t.string(value)
		if not stringSuccess then
			return false
		end

		if string.match(value, pattern) == nil then
			return false
		end

		return true
	end
end

function t.optional(check)
	assert(t.callback(check))
	return function(value)
		if value == nil then
			return true
		end
		local success = check(value)
		if success then
			return true
		else
			return false
		end
	end
end

function t.tuple(...)
	local checks = {...}
	return function(...)
		local args = {...}
		for i = 1, #checks do
			local success = checks[i](args[i])
			if success == false then
				return false
			end
		end
		return true
	end
end

function t.keys(check)
	assert(t.callback(check))
	return function(value)
		local tableSuccess = t.table(value)
		if tableSuccess == false then
			return false
		end

		for key in pairs(value) do
			local success = check(key)
			if success == false then
				return false
			end
		end

		return true
	end
end

function t.values(check)
	assert(t.callback(check))
	return function(value)
		local tableSuccess = t.table(value)
		if tableSuccess == false then
			return false
		end

		for _, val in pairs(value) do
			local success = check(val)
			if success == false then
				return false
			end
		end

		return true
	end
end

function t.map(keyCheck, valueCheck)
	assert(t.callback(keyCheck), t.callback(valueCheck))
	local keyChecker = t.keys(keyCheck)
	local valueChecker = t.values(valueCheck)
	return function(value)
		local keySuccess = keyChecker(value)
		if not keySuccess then
			return false
		end

		local valueSuccess = valueChecker(value)
		if not valueSuccess then
			return false
		end

		return true
	end
end

do
	local arrayKeysCheck = t.keys(t.integer)

	function t.array(check)
		assert(t.callback(check))
		local valuesCheck = t.values(check)
		return function(value)
			local keySuccess = arrayKeysCheck(value)
			if keySuccess == false then
				return false
			end

			-- # is unreliable for sparse arrays
			-- Count upwards using ipairs to avoid false positives from the behavior of #
			local arraySize = 0

			for _, _ in ipairs(value) do
				arraySize = arraySize + 1
			end

			for key in pairs(value) do
				if key < 1 or key > arraySize then
					return false
				end
			end

			local valueSuccess = valuesCheck(value)
			if not valueSuccess then
				return false
			end

			return true
		end
	end
end

do
	local callbackArray = t.array(t.callback)

	function t.union(...)
		local checks = {...}
		assert(callbackArray(checks))
		return function(value)
			for _, check in pairs(checks) do
				if check(value) then
					return true
				end
			end
			return false
		end
	end

	function t.intersection(...)
		local checks = {...}
		assert(callbackArray(checks))
		return function(value)
			for _, check in pairs(checks) do
				local success = check(value)
				if not success then
					return false
				end
			end
			return true
		end
	end
end

do
	local checkInterface = t.map(t.any, t.callback)

	function t.interface(checkTable)
		assert(checkInterface(checkTable))
		return function(value)
			local tableSuccess = t.table(value)
			if tableSuccess == false then
				return false
			end

			for key, check in pairs(checkTable) do
				local success = check(value[key])
				if success == false then
					return false
				end
			end
			return true
		end
	end

	function t.strictInterface(checkTable)
		assert(checkInterface(checkTable))
		return function(value)
			local tableSuccess = t.table(value)
			if tableSuccess == false then
				return false
			end

			for key, check in pairs(checkTable) do
				local success = check(value[key])
				if success == false then
					return false
				end
			end

			for key in pairs(value) do
				if not checkTable[key] then
					return false
				end
			end

			return true
		end
	end
end

function t.instanceOf(className)
	assert(t.string(className))
	return function(value)
		local instanceSuccess = t.Instance(value)
		if not instanceSuccess then
			return false
		end

		if value.ClassName ~= className then
			return false
		end

		return true
	end
end
t.instance = t.instanceOf

function t.instanceIsA(className)
	assert(t.string(className))
	return function(value)
		local instanceSuccess = t.Instance(value)
		if not instanceSuccess then
			return false
		end

		if not value:IsA(className) then
			return false
		end

		return true
	end
end

function t.enum(enum)
	assert(t.Enum(enum))
	return function(value)
		local enumItemSuccess = t.EnumItem(value)
		if not enumItemSuccess then
			return false
		end

		if value.EnumType == enum then
			return true
		else
			return false
		end
	end
end

do
	local checkWrap = t.tuple(t.callback, t.callback)

	function t.wrap(callback, checkArgs)
		assert(checkWrap(callback, checkArgs))
		return function(...)
			assert(checkArgs(...))
			return callback(...)
		end
	end
end

function t.strict(check)
	return function(...)
		assert(check(...))
	end
end

do
	local checkChildren = t.map(t.string, t.callback)
	function t.children(checkTable)
		assert(checkChildren(checkTable))

		return function(value)
			local instanceSuccess = t.Instance(value)
			if not instanceSuccess then
				return false
			end

			local childrenByName = {}
			for _, child in pairs(value:GetChildren()) do
				local name = child.Name
				if checkTable[name] then
					if childrenByName[name] then
						return false
					end
					childrenByName[name] = child
				end
			end

			for name, check in pairs(checkTable) do
				local success = check(childrenByName[name])
				if not success then
					return false
				end
			end

			return true
		end
	end
end

return t