return function()
	local t = require(script.Parent)

	it("should support basic types", function()
		assert(t.any(""))
		assert(t.boolean(true))
		assert(t.none(nil))
		assert(t.number(1))
		assert(t.string("foo"))
		assert(t.table({}))

		assert(not (t.any(nil)))
		assert(not (t.boolean("true")))
		assert(not (t.none(1)))
		assert(not (t.number(true)))
		assert(not (t.string(true)))
		assert(not (t.table(82)))
	end)

	it("should support special number types", function()
		local maxTen = t.numberMax(10)
		local minTwo = t.numberMin(2)
		local maxTenEx = t.numberMaxExclusive(10)
		local minTwoEx = t.numberMinExclusive(2)
		local constrainedEightToEleven = t.numberConstrained(8, 11)
		local constrainedEightToElevenEx = t.numberConstrainedExclusive(8, 11)

		assert(maxTen(5))
		assert(maxTen(10))
		assert(not (maxTen(11)))
		assert(not (maxTen()))

		assert(minTwo(5))
		assert(minTwo(2))
		assert(not (minTwo(1)))
		assert(not (minTwo()))

		assert(maxTenEx(5))
		assert(maxTenEx(9))
		assert(not (maxTenEx(10)))
		assert(not (maxTenEx()))

		assert(minTwoEx(5))
		assert(minTwoEx(3))
		assert(not (minTwoEx(2)))
		assert(not (minTwoEx()))

		assert(not (constrainedEightToEleven(7)))
		assert(constrainedEightToEleven(8))
		assert(constrainedEightToEleven(9))
		assert(constrainedEightToEleven(11))
		assert(not (constrainedEightToEleven(12)))
		assert(not (constrainedEightToEleven()))

		assert(not (constrainedEightToElevenEx(7)))
		assert(not (constrainedEightToElevenEx(8)))
		assert(constrainedEightToElevenEx(9))
		assert(not (constrainedEightToElevenEx(11)))
		assert(not (constrainedEightToElevenEx(12)))
		assert(not (constrainedEightToElevenEx()))
	end)

	it("should support optional types", function()
		local check = t.optional(t.string)
		assert(check(""))
		assert(check())
		assert(not (check(1)))
	end)

	it("should support tuple types", function()
		local myTupleCheck = t.tuple(t.number, t.string, t.optional(t.number))
		assert(myTupleCheck(1, "2", 3))
		assert(myTupleCheck(1, "2"))
		assert(not (myTupleCheck(1, "2", "3")))
	end)

	it("should support union types", function()
		local numberOrString = t.union(t.number, t.string)
		assert(numberOrString(1))
		assert(numberOrString("1"))
		assert(not (numberOrString(nil)))
	end)

	it("should support literal types", function()
		local checkSingle = t.literal("foo")
		local checkUnion = t.union(t.literal("foo"), t.literal("bar"), t.literal("oof"))

		assert(checkSingle("foo"))
		assert(checkUnion("foo"))
		assert(checkUnion("bar"))
		assert(checkUnion("oof"))

		assert(not (checkSingle("FOO")))
		assert(not (checkUnion("FOO")))
		assert(not (checkUnion("BAR")))
		assert(not (checkUnion("OOF")))
	end)

	it("should support multiple literal types", function()
		local checkSingle = t.literal("foo")
		local checkUnion = t.literal("foo", "bar", "oof")

		assert(checkSingle("foo"))
		assert(checkUnion("foo"))
		assert(checkUnion("bar"))
		assert(checkUnion("oof"))

		assert(not (checkSingle("FOO")))
		assert(not (checkUnion("FOO")))
		assert(not (checkUnion("BAR")))
		assert(not (checkUnion("OOF")))
	end)

	it("should support intersection types", function()
		local integerMax5000 = t.intersection(t.integer, t.numberMax(5000))
		assert(integerMax5000(1))
		assert(not (integerMax5000(5001)))
		assert(not (integerMax5000(1.1)))
		assert(not (integerMax5000("1")))
	end)

	describe("array", function()
		it("should support array types", function()
			local stringArray = t.array(t.string)
			local anyArray = t.array(t.any)
			local stringValues = t.values(t.string)
			assert(not (anyArray("foo")))
			assert(anyArray({1, "2", 3}))
			assert(not (stringArray({1, "2", 3})))
			assert(not (stringArray()))
			assert(not (stringValues()))
			assert(anyArray({"1", "2", "3"}, t.string))
			assert(not (anyArray({
				foo = "bar"
			})))
			assert(not (anyArray({
				[1] = "non",
				[5] = "sequential"
			})))
		end)

		it("should not be fooled by sparse arrays", function()
			local anyArray = t.array(t.any)

			assert(not (anyArray({
				[1] = 1,
				[2] = 2,
				[4] = 4,
			})))
		end)
	end)

	it("should support map types", function()
		local stringNumberMap = t.map(t.string, t.number)
		assert(stringNumberMap({}))
		assert(stringNumberMap({a = 1}))
		assert(not (stringNumberMap({[1] = "a"})))
		assert(not (stringNumberMap({a = "a"})))
		assert(not (stringNumberMap()))
	end)

	it("should support interface types", function()
		local IVector3 = t.interface({
			x = t.number,
			y = t.number,
			z = t.number,
		})

		assert(IVector3({
			w = 0,
			x = 1,
			y = 2,
			z = 3,
		}))

		assert(not (IVector3({
			w = 0,
			x = 1,
			y = 2,
		})))
	end)

	it("should support strict interface types", function()
		local IVector3 = t.strictInterface({
			x = t.number,
			y = t.number,
			z = t.number,
		})

		assert(not (IVector3(0)))

		assert(not (IVector3({
			w = 0,
			x = 1,
			y = 2,
			z = 3,
		})))

		assert(not (IVector3({
			w = 0,
			x = 1,
			y = 2,
		})))

		assert(IVector3({
			x = 1,
			y = 2,
			z = 3,
		}))
	end)

	it("should support deep interface types", function()
		local IPlayer = t.interface({
			name = t.string,
			inventory = t.interface({
				size = t.number
			})
		})

		assert(IPlayer({
			name = "TestPlayer",
			inventory = {
				size = 1
			}
		}))

		assert(not (IPlayer({
			inventory = {
				size = 1
			}
		})))

		assert(not (IPlayer({
			name = "TestPlayer",
			inventory = {
			}
		})))

		assert(not (IPlayer({
			name = "TestPlayer",
		})))
	end)

	it("should support deep optional interface types", function()
		local IPlayer = t.interface({
			name = t.string,
			inventory = t.optional(t.interface({
				size = t.number
			}))
		})

		assert(IPlayer({
			name = "TestPlayer"
		}))

		assert(not (IPlayer({
			name = "TestPlayer",
			inventory = {
			}
		})))

		assert(IPlayer({
			name = "TestPlayer",
			inventory = {
				size = 1
			}
		}))
	end)

	it("should support Roblox Instance types", function()
		local stringValueCheck = t.instanceOf("StringValue")
		local stringValue = Instance.new("StringValue")
		local boolValue = Instance.new("BoolValue")

		assert(stringValueCheck(stringValue))
		assert(not (stringValueCheck(boolValue)))
		assert(not (stringValueCheck()))
	end)

	it("should support Roblox Instance types inheritance", function()
		local guiObjectCheck = t.instanceIsA("GuiObject")
		local frame = Instance.new("Frame")
		local textLabel = Instance.new("TextLabel")
		local stringValue = Instance.new("StringValue")

		assert(guiObjectCheck(frame))
		assert(guiObjectCheck(textLabel))
		assert(not (guiObjectCheck(stringValue)))
		assert(not (guiObjectCheck()))
	end)

	it("should support Roblox Enum types", function()
		local sortOrderEnumCheck = t.enum(Enum.SortOrder)
		assert(t.Enum(Enum.SortOrder))
		assert(not (t.Enum("Enum.SortOrder")))

		assert(t.EnumItem(Enum.SortOrder.Name))
		assert(not (t.EnumItem("Enum.SortOrder.Name")))

		assert(sortOrderEnumCheck(Enum.SortOrder.Name))
		assert(sortOrderEnumCheck(Enum.SortOrder.Custom))
		assert(not (sortOrderEnumCheck(Enum.EasingStyle.Linear)))
		assert(not (sortOrderEnumCheck()))
	end)

	it("should support Roblox RBXScriptSignal", function()
		assert(t.RBXScriptSignal(game.ChildAdded))
		assert(not (t.RBXScriptSignal(nil)))
		assert(not (t.RBXScriptSignal(Vector3.new())))
	end)

	-- TODO: Add this back when Lemur supports it
	-- it("should support Roblox RBXScriptConnection", function()
	-- 	local conn = game.ChildAdded:Connect(function() end)
	-- 	assert(t.RBXScriptConnection(conn))
	-- 	assert(not (t.RBXScriptConnection(nil)))
	-- 	assert(not (t.RBXScriptConnection(Vector3.new())))
	-- end)

	it("should support wrapping function types", function()
		local checkFoo = t.tuple(t.string, t.number, t.optional(t.string))
		local foo = t.wrap(function(a, b, c)
			local result = string.format("%s %d", a, b)
			if c then
				result = result .. " " .. c
			end
			return result
		end, checkFoo)

		assert(not (pcall(foo)))
		assert(not (pcall(foo, "a")))
		assert(not (pcall(foo, 2)))
		assert(pcall(foo, "a", 1))
		assert(pcall(foo, "a", 1, "b"))
	end)

	it("should support strict types", function()
		local myType = t.strict(t.tuple(t.string, t.number))
		assert(not (pcall(function()
			myType("a", "b")
		end)))
		assert(pcall(function()
			myType("a", 1)
		end))
	end)

	it("should support common OOP types", function()
		local MyClass = {}
		MyClass.__index = MyClass

		function MyClass.new()
			local self = setmetatable({}, MyClass)
			return self
		end

		local function instanceOfClass(class)
			return function(value)
				local tableSuccess, tableErrMsg = t.table(value)
				if not tableSuccess then
					return false, tableErrMsg or ""
				end

				local mt = getmetatable(value)
				if not mt or mt.__index ~= class then
					return false, "bad member of class"
				end

				return true
			end
		end

		local instanceOfMyClass = instanceOfClass(MyClass)

		local myObject = MyClass.new()
		assert(instanceOfMyClass(myObject))
		assert(not (instanceOfMyClass({})))
		assert(not (instanceOfMyClass()))
	end)

	it("should not treat NaN as numbers", function()
		assert(t.number(1))
		assert(not (t.number(0/0)))
		assert(not (t.number("1")))
	end)

	it("should not treat numbers as NaN", function()
		assert(not (t.nan(1)))
		assert(t.nan(0/0))
		assert(not (t.nan("1")))
	end)

	it("should allow union of number and NaN", function()
		local numberOrNaN = t.union(t.number, t.nan)
		assert(numberOrNaN(1))
		assert(numberOrNaN(0/0))
		assert(not (numberOrNaN("1")))
	end)

	it("should support non-string keys for interfaces", function()
		local key = {}
		local myInterface = t.interface({ [key] = t.number })
		assert(myInterface({ [key] = 1 }))
		assert(not (myInterface({ [key] = "1" })))
	end)

	it("should support failing on non-string keys for strict interfaces", function()
		local myInterface = t.strictInterface({ a = t.number })
		assert(not (myInterface({ a = 1, [{}] = 2 })))
	end)

	it("should support children", function()
		local myInterface = t.interface({
			buttonInFrame = t.intersection(t.instanceOf("Frame"), t.children({
				MyButton = t.instanceOf("ImageButton")
			}))
		})

		assert(not (t.children({})(5)))
		assert(not (myInterface({ buttonInFrame = Instance.new("Frame") })))

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "MyButton"
			assert(myInterface({ buttonInFrame = frame }))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "NotMyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("TextButton", frame)
			button.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button1 = Instance.new("ImageButton", frame)
			button1.Name = "MyButton"
			local button2 = Instance.new("ImageButton", frame)
			button2.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end
	end)

	it("should support t.instanceOf shorthand", function()
		local myInterface = t.interface({
			buttonInFrame = t.instanceOf("Frame", {
				MyButton = t.instanceOf("ImageButton")
			})
		})

		assert(not (t.children({})(5)))
		assert(not (myInterface({ buttonInFrame = Instance.new("Frame") })))

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "MyButton"
			assert(myInterface({ buttonInFrame = frame }))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "NotMyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("TextButton", frame)
			button.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button1 = Instance.new("ImageButton", frame)
			button1.Name = "MyButton"
			local button2 = Instance.new("ImageButton", frame)
			button2.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end
	end)

	it("should support t.instanceIsA shorthand", function()
		local myInterface = t.interface({
			buttonInFrame = t.instanceIsA("Frame", {
				MyButton = t.instanceIsA("ImageButton")
			})
		})

		assert(not (t.children({})(5)))
		assert(not (myInterface({ buttonInFrame = Instance.new("Frame") })))

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "MyButton"
			assert(myInterface({ buttonInFrame = frame }))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("ImageButton", frame)
			button.Name = "NotMyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button = Instance.new("TextButton", frame)
			button.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end

		do
			local frame = Instance.new("Frame")
			local button1 = Instance.new("ImageButton", frame)
			button1.Name = "MyButton"
			local button2 = Instance.new("ImageButton", frame)
			button2.Name = "MyButton"
			assert(not (myInterface({ buttonInFrame = frame })))
		end
	end)

	it("should support t.match", function()
		local check = t.match("%d+")
		assert(check("123"))
		assert(not (check("abc")))
		assert(not (check()))
	end)

	it("should support t.keyOf", function()
		local myNewEnum = {
			OptionA = {},
			OptionB = {},
		}
		local check = t.keyOf(myNewEnum)
		assert(check("OptionA"))
		assert(not (check("OptionC")))
	end)

	it("should support t.valueOf", function()
		local myNewEnum = {
			OptionA = {},
			OptionB = {},
		}
		local check = t.valueOf(myNewEnum)
		assert(check(myNewEnum.OptionA))
		assert(not (check(1010)))
	end)
end