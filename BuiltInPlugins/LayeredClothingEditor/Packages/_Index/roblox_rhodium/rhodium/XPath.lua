local XPath = {}
XPath.__index = XPath
XPath.__type = "XPath"

local specialChars = [[\.=[],]]
local specialCharMap = {}
for i = 1, #specialChars do
	local ch = specialChars:sub(i, i)
	specialCharMap[ch] = true
end

function XPath.addSlash(str)
	local tab = {}
	for i = 1, str:len() do
		local ch = str:sub(i, i)
		if specialCharMap[ch] then
			table.insert(tab, "\\")
		end
		table.insert(tab, ch)
	end
	return table.concat(tab)
end

function XPath.removeSlash(str)
	local tab = {}
	local isBackSlash = false
	for i = 1, str:len() do
		local ch = str:sub(i, i)
		if ch  == "\\" and isBackSlash == false then
			isBackSlash = true
		else
			if isBackSlash == true then
				isBackSlash = false
			end
			table.insert(tab, ch)
		end
	end
	return table.concat(tab)
end

local function splitByCharWithSlash(s, token)
	local result = {}
	if s == nil or s == "" then return result end
	local isBackSlash = false
	local lastIndex = 1
	for i = 1, s:len() do
		local ch = s:sub(i, i)
		if ch  == "\\" and isBackSlash == false then
			isBackSlash = true
		else
			if isBackSlash == true then
				isBackSlash = false
			else
				if ch == token then
					table.insert(result, (s:sub(lastIndex, i-1)))
		  lastIndex = i+1
		end
			end
		end
	end
	table.insert(result, (s:sub(lastIndex, s:len())))
	return result
end

local function deepCopy(t)
	local t2 = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			t2[k] = deepCopy(v)
		else
			t2[k] = v
		end
	end
	return t2
end

function XPath.new(obj, root)
	local self = {data = {}, root = root, waitDelay = 0.2, waitTimeOut = 2}
	setmetatable(self, XPath)

	if type(obj) == "string" then
		self:fromString(obj)
	elseif type(obj) == "userdata" then
		local current = obj
		while current do
			local name = current.Name
			if current.ClassName == "DataModel" then
				name = "game"
			end
			table.insert(self.data, 1, {name = name})
			current = current.Parent
		end
	elseif getmetatable(obj).__type == XPath.__type then
		return obj:copy()
	else
		error("unknown parameter ", obj)
	end
	return self
end

function XPath:size()
	return #self.data
end

function XPath:mergeFilter(index, additionalFilter)
	if index > self:size() then error("bad index") end
	local filter = self.data[index].filter or {}
	local filterDict = {}
	for _, item in ipairs(filter) do
		filterDict[item.key] = item.value
	end
	if additionalFilter then
		for _, item in ipairs(additionalFilter) do
			filterDict[item.key] = tostring(item.value)
		end
	end
	local newFilter = {}
	for k, v in pairs(filterDict) do
		table.insert(newFilter, {key = k, value = v})
	end
	self.data[index].filter = newFilter
	return self
end

function XPath:fromString(str)
	local inBracket = false
	local isBackSlash = false
	local data = {}
	local lastIndex = 1
	str = str .. "."
	for i = 1, str:len() do
		local ch = str:sub(i, i)
		if ch == "\\" and isBackSlash == false then
			isBackSlash = true
		else
			if isBackSlash == true then
				isBackSlash = false
			else
				if ch == "." then
					if not inBracket then
						table.insert(data, {name = str:sub(lastIndex, i-1)})
						lastIndex = i+1
					end
				elseif ch == "[" then
					if inBracket == true then
						error("no nested bracket allowed: " .. str)
					end
					inBracket = true
				elseif ch == "]" then
					if not inBracket then
						error("unbalanced brackets: " .. str)
					end
					inBracket = false
				end
			end
		end
	end
	if inBracket == true then error("unbalanced brackets: " .. str) end

	for i = 1, #data do
		local name, filters = data[i].name:match("%s*(.*[^\\])%[(.*[^\\])%]%s*")
		if name == nil then
			filters = ""
			name = data[i].name
		end
		if name ~= nil then
			data[i].name = XPath.removeSlash(name)
			local filterArray = splitByCharWithSlash(filters, ",")
			local filterObjs = {}
			for _, filter in ipairs(filterArray) do
				local key, value = filter:match("^%s*(.-[^\\])%s*=%s*(.-)%s*$")
				if key then
					table.insert(filterObjs, {key = key, value = value})
				end
			end
			data[i].filter = filterObjs
		end
	end
	self.data = data
end

function XPath:copy()
	local result = deepCopy(self)
	setmetatable(result, XPath)
	return result
end


function XPath:parent()
	local newOne = self:copy()
	if #newOne.data <= 1 then
		--error("this is the root")
		return newOne
	else
		table.remove(newOne.data, #newOne.data)
	end
	return newOne
end

function XPath:_itemToString(item)
	local result = XPath.addSlash(item.name)
	if item.filter and #item.filter > 0 then
		local filter = {}
		for _, v in ipairs(item.filter) do
			table.insert(filter, v.key .. " = " ..v.value)
		end
		result = result .. "[" .. table.concat(filter, ", ") .. "]"
	end
	return result
end

function XPath:toString(arg)
	if arg == nil then
		local tab = {}
		for _, item in ipairs(self.data) do
			table.insert(tab, self:_itemToString(item))
		end
		return table.concat(tab, ".")
	elseif type(arg) == "number" then
		if arg < 0 then arg = self:size() + arg + 1 end
		if arg > self:size() or arg < 1 then error("invalid index") end
		return self:_itemToString(self.data[arg])
	elseif type(arg) == "table" then
		return self:_itemToString(arg)
	end
end

function XPath:hasChild(child)
	return child:relative(self) ~= nil
end

function XPath:relative(root)
	if self:size()<#root.data then return nil end
	local newRoot = root:copy()
	local newSelf = self:copy()

	while #newRoot.data > 0 do
		if newRoot.data[1].name ~= newSelf.data[1].name then return nil end
		table.remove(newRoot.data, 1)
		table.remove(newSelf.data, 1)
	end
	return newSelf
end


function XPath:cat(path)
	local newOne = self:copy()
	for _, k in ipairs(path.data) do
		table.insert(newOne.data, k)
	end
	return newOne
end

function XPath:clearFilter()
	for i = 1, self:size() do
		self.data[i].filter = nil
	end
	return self
end

local function getProperty(instance, property)
	local state, result = pcall(function() return instance[property] end )
	return state == true and result or nil
end

local function propertyEqual(lhs, rhs)
	return tostring(lhs) == tostring(rhs)
end

local function propertyMatch(prop, expr)
	prop = tostring(prop)
	expr = tostring(expr)
	return expr == "*" or prop == expr
end

local function findChildrenByName(instance, name)
	local children = instance:GetChildren()
	local result = {}
	for _, child in ipairs(children) do
		if propertyMatch(getProperty(child, "Name"), name) then
			table.insert(result, child)
		end
	end
	-- for game.Players, their is no child "LocalPlayer", but you can access it.
	if #result == 0 then
		local instance = getProperty(instance, name)
		if instance then
			table.insert(result, instance)
		end
	end
	return result
end

local function findChildren(instances, name)
	local result = {}
	for _, instance in ipairs(instances) do
		local children = findChildrenByName(instance, name)
		for _, child in ipairs(children) do
			table.insert(result, child)
		end
	end
	return result
end

local function findCandidates(instances, path)
	for _, name in ipairs(path) do
		instances = findChildren(instances, name)
	end
	return instances
end

local function passFilter(instance, filter)
	local key = filter.key
	local path, propertyName = key:match("^%.?(.*[^\\])%.(%w-)$")
	if propertyName == nil then
		path = ""
		propertyName = key:match("^%.?(%w-)$")
	end
	local pathData = splitByCharWithSlash(path, ".")
	for i = 1, #pathData do pathData[i] = XPath.removeSlash(pathData[i]) end
	local canditates = findCandidates({instance}, pathData)
	for _, canditate in ipairs(canditates) do
		local property = getProperty(canditate, propertyName)
		if propertyMatch(property, XPath.removeSlash(filter.value)) then
			return true
		end
	end
	return false
end

local function passFilters(instance, filters)
	for _, filter in ipairs(filters) do
		if not passFilter(instance, filter) then
			return false
		end
	end
	return true
end

local function applyFilters(canditates, filters)
	if filters == nil then return canditates end
	local result = {}
	for _, canditate in ipairs(canditates) do
		if passFilters(canditate, filters) then
			table.insert(result, canditate)
		end
	end
	return result
end

function XPath:getFirstInstance()
	local instances = self:getInstances()
	if #instances == 0 then return nil else return instances[1] end
end

function XPath:getInstances()
	if self:size() <1 then error("instance " .. self:toString() .. " does not exist") end

	local rootInstance = nil
	local rootName = self.data[1].name

	if rootName == "game" then
		rootInstance = game
	elseif rootName == "PluginGuiService" then
		rootInstance = game:GetService("PluginGuiService")
	end

	if self.root == nil and rootInstance == nil then
		error("instance " .. self:toString() .. " does not exist")
	end

	local instances = {self.root or rootInstance}
	local i = self.root and 1 or 2
	while i <= self:size() do
		local name = self.data[i].name
		local filters = self.data[i].filter
		local candidates = findChildren(instances, name)
		instances = applyFilters(candidates, filters)
		if #instances == 0 then return instances, i-1 end
		i = i + 1
	end
	return instances, i-1
end

function XPath:setWait(timeOut, delay)
	self.waitDelay = delay or self.waitDelay
	self.waitTimeOut = timeOut or self.waitTimeOut
	return self
end

function XPath:waitFor(execute, condition, delay, timeOut)
	delay = delay or self.waitDelay
	timeOut = timeOut or self.waitTimeOut
	timeOut = tick()+timeOut
	while true do
		local result = execute()
		if condition(result) then
			return result, true
		end
		wait(delay)
		if tick() > timeOut then return result, false end
	end
end

function XPath:waitForFirstInstance()
--	return self:waitForInstances(function(instances) return #instances >0 end)[1]
	local instances = self:waitForNInstances(1)
	if instances ~= nil and #instances > 0 then return instances[1] end
	return nil
end

function XPath:waitForInstances(condition)
	if type(condition) ~= "function" then error("arg #1 should be a function") end
	return self:waitFor(function()
		return self:getInstances()
	end, condition)
end

function XPath:waitForDisappear()
	local _, state = self:waitForInstances(function(instances) return #instances == 0 end)
	return state == true
end

function XPath:waitForNInstances(n)
	return self:waitForInstances(function(instances)
		return #instances >= n
	end)
end

local function makeInstance(className, props, children)
	local instance = Instance.new(className)
	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end
	if props then
		for k, v in pairs(props) do
			instance[k] = v
		end
	end
	return instance
end

local function test()
	local function closeTo(lhs, rhs, err)
		return math.abs(lhs-rhs) <= err
	end

	local specialChars = [[special chars !"#$%&'()*+,-./:;<=>?@[]\^_`{|}~]]
	local convertedSpecialChars = [[special chars !"#$%&'()*+\,-\./:;<\=>?@\[\]\\^_`{|}~]]

	local root
	if game.Workspace:FindFirstChild("root") == nil then
		root = makeInstance("Folder",
			{
				Name = "root",
				Parent = game.Workspace
			}, {
				makeInstance("Frame", {Name = "Frame"}, {
					makeInstance("TextButton", {
						Text = "Button1"
					}),
					makeInstance("TextLabel", {
						Text = "Label1"
					}),
					makeInstance("ImageButton", {

					})
				}),
				makeInstance("Frame", {Name = "Frame"}, {
					makeInstance("TextButton", {
						Text = "Button2"
					}),
					makeInstance("TextLabel", {
						Text = "Label2"
					})
				}),
				makeInstance("Frame", {Name = "Frame"}, {
					makeInstance("TextLabel", {Text = "Label3"}),
					makeInstance("Frame", {Name = specialChars}, {
						makeInstance("TextButton", {Name = "TextButton3"})
					}),
					makeInstance("TextLabel", {Name = "SpecialCharLabel", Text = specialChars})
				})
		})
	end

	local containerPath = XPath.new("game.Workspace.root.Frame")

	local getContainerDetail = function(root)
		return {
			textButton = XPath.new("TextButton", root),
			textLabel = XPath.new("TextLabel", root),
		}
	end

	local createSearch = function(container, relativePath, property, value)
		local rootPath = container:copy()
		local filter = {{key = "." .. relativePath:toString().."."..property, value = value}}
		rootPath:mergeFilter(rootPath:size(), filter)
		return rootPath
	end

	local rootPath = createSearch(containerPath, getContainerDetail().textButton, "Text", "Button2")
	print("createSearch:", rootPath:toString())
	local rootInstance = rootPath:waitForFirstInstance()
	assert(rootInstance)

	local containerDetail = getContainerDetail(rootInstance)

	local label2 = containerDetail.textLabel:waitForFirstInstance()
	assert(label2.Text == "Label2")

	print("relative path test")

	local path = XPath.new("game.Workspace.root.Frame[.TextButton.Text = Button2]")
	local instance = path:getFirstInstance()
	assert(instance)
	local relativePath = XPath.new("TextButton", instance)
	local instance = relativePath:getFirstInstance()
	assert(instance.Text == "Button2")

	local path = XPath.new("game.Workspace.root.Frame[.TextButton.Text = Button2, .ClassName = Frame].TextLabel")
	local instance = path:getFirstInstance()
	assert(instance.Text=="Label2")
	local newPathString = XPath.new(instance):toString()
	assert(newPathString=="game.Workspace.root.Frame.TextLabel")

	local pathStr = "game.Workspace.root.Frame[."..convertedSpecialChars..".TextButton3.Name = TextButton3].TextLabel"
	local path = XPath.new(pathStr)
	assert(path:toString()==pathStr)
	local instance = path:getFirstInstance()
	assert(instance.Text=="Label3")

	local pathStr = "game.Workspace.root.Frame[.SpecialCharLabel.Text = "..convertedSpecialChars.."].TextLabel"
	local path = XPath.new(pathStr)
	assert(path:toString()==pathStr)
	local instance = path:getFirstInstance()
	assert(instance.Text=="Label3")

	local pathStr = "game.Workspace.root.Frame."..convertedSpecialChars..".TextButton3"
	local path = XPath.new(pathStr)
	local newPathStr = path:toString()
	assert(newPathStr==pathStr)
	local instance = path:getFirstInstance()
	assert(instance.Name=="TextButton3")

	local rootPath = XPath.new("game.Workspace.root")
	local path = XPath.new("game.Workspace.root.Frame[.TextButton.Text = Button2, .ClassName = Frame].TextLabel")
	local relativePath = path:relative(rootPath)
	relativePath:clearFilter()

	print("testing getFirstInstance()")
	print(path:toString())
	local instance = path:getFirstInstance()
	assert(instance.Text == "Label2")

	print("testing wildcard *")
	path = XPath.new("game.Workspace.root.*[.TextButton.Text = Button2].TextLabel")
	instance = path:getFirstInstance()
	assert(instance.Text == "Label2")

	path = XPath.new("game.Workspace.root.*[.ImageButton.Name = *].TextLabel")
	instance = path:getFirstInstance()
	assert(instance.Text == "Label1")

	local timeBefore = nil
	print("testing timeout waitForNInstances() ")
	path = XPath.new("game.Workspace.root.Frame.TextLabel")
	timeBefore = tick()
	local instances, state = path:setWait(2):waitForNInstances(5)
	assert(closeTo(tick() - timeBefore, 2, 0.5))
	assert(state == false)

	print("testing normal waitForNInstances() ")
	timeBefore = tick()
	spawn(function()
		wait(2)
		makeInstance("Frame", {
				Name = "Frame",
				Parent = game.Workspace.root
			}, {
			makeInstance("TextButton", {
				Text = "Button3"
			}),
			makeInstance("TextLabel", {
				Text = "Label3"
			})
		})
	end)
	local instances = path:setWait(5):waitForNInstances(5)
	assert(closeTo(tick() - timeBefore, 2, 0.5))
	assert(#instances >= 5)

	print("testing  getFirstInstance() ")
	path = XPath.new("game.Workspace.root.Frame[.TextButton.Text = Button3]")
	instance = path:getFirstInstance()
	assert(instance.TextButton.Text == "Button3")

	print("testing timeout waitForDisappear() ")
	timeBefore = tick()
	local notExist = path:setWait(2):waitForDisappear()
	assert(notExist == false)
	assert(closeTo(tick() - timeBefore, 2, 0.5))

	print("testing normal waitForDisappear() ")
	timeBefore = tick()
	spawn(function()
		wait(2)
		instance:Destroy()
	end)
	local notExist = path:setWait(5):waitForDisappear()
	assert(closeTo(tick() - timeBefore, 2, 0.5))
	assert(notExist == true)

	print("test finised")
end

--test()

return XPath