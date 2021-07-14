--[[
	Create a class called _name_ with the specified _constructor_. The constructor should return a
	plain table which will be turned into an instance of _Class_ from a call to `Class.new(...)`.
	
	@example
		-- Create a simple Vehicle class
		local Vehicle = class("Vehicle", function(wheelCount: number) return 
			{
				speed = 0,
				wheelCount = wheelCount
			}
		end)
		function Vehicle:drive(speed)
			self.speed = speed
		end
		-- Create a car instance
		local car = Vehicle.new(4)
		car.wheelCount --> 4
		car.speed --> 0
		-- Drive the car
		car:drive(10)
		car.speed --> 10
		
	@usage When using Dash classes, private fields should be prefixed with `_` to avoid accidental access.
	@usage A private field should only be accessed by a method of the class itself, though Rodash
		does not restrict this in code.
	@usage Public fields are recommended when there is no complex access logic e.g. `position.x`
]]
local Dash = script.Parent
local Types = require(Dash.Types)

local function throwNotImplemented(tags: Types.Table)
	local Error = require(Dash.Error)
	local NotImplemented = Error.new("NotImplemented", [[The method "{methodName}" is not implemented on the class "{className}"]])
	NotImplemented:throw(tags)
end

export type Constructor = () -> Types.Table

local function class(name: string, constructor: Constructor?)
	constructor = constructor or function()
		return {}
	end
	local Class = {
		name = name
	}
	--[[
		Return a new instance of the class, passing any arguments to the specified constructor.
		@example
			local Car = class("Car", function(speed)
				return {
					speed = speed
				}
			end)
			local car = Car.new(5)
			pretty(car) --> 'Car {speed = 5}'
	]]
	function Class.new(...)
		local instance = constructor(...)
		setmetatable(
			instance,
			{
				__index = Class,
				__tostring = Class.toString,
				__eq = Class.equals,
				__lt = Class.__lt,
				__le = Class.__le,
				__add = Class.__add,
				__sub = Class.__sub,
				__mul = Class.__mul,
				__div = Class.__div,
				__mod = Class.__mod
			}
		)
		instance.Class = Class
		instance:_init(...)
		return instance
	end
	--[[
		Run after the instance has been properly initialized, allowing methods on the instance to
		be used.
		@example
			local Vehicle = dash.class("Vehicle", function(wheelCount) return 
				{
					speed = 0,
					wheelCount = wheelCount
				}
			end)
			-- Let's define a static private function to generate a unique id for each vehicle.
			function Vehicle._getNextId()
				Vehicle._nextId = Vehicle._nextId + 1
				return Vehicle._nextId
			end
			Vehicle._nextId = 0
			-- A general purpose init function may call other helper methods
			function Vehicle:_init()
				self._id = self:_generateId()
			end
			-- Assign an id to the new instance
			function Vehicle:_generateId()
				return format("#{}: {} wheels", Vehicle._getNextId(), self.wheelCount)
			end
			-- Return the id if the instance is represented as a string 
			function Vehicle:toString()
				return self._id
			end
			local car = Vehicle.new(4)
			tostring(car) --> "#1: 4 wheels"
	]]
	function Class:_init()
	end

	--[[
		Returns `true` if _value_ is an instance of _Class_ or any sub-class.
		@example
			local Vehicle = dash.class("Vehicle", function(wheelCount) return 
				{
					speed = 0,
					wheelCount = wheelCount
				}
			end)
			local Car = Vehicle:extend("Vehicle", function()
				return Vehicle.constructor(4)
			end)
			local car = Car.new()
			car.isInstance(Car) --> true
			car.isInstance(Vehicle) --> true
			car.isInstance(Bike) --> false
	]]
	function Class.isInstance(value)
		local ok, isInstance = pcall(function()
			local metatable = getmetatable(value)
			while metatable do
				if metatable.__index == Class then
					return true
				end
				metatable = getmetatable(metatable.__index)
			end
			return false
		end)
		return ok and isInstance
	end

	--[[
		Create a subclass of _Class_ with a new _name_ that inherits the metatable of _Class_,
		optionally overriding the _constructor_ and providing additional _decorators_.
		The super-constructor can be accessed with `Class.constructor`.
		Super methods can be accessed using `Class.methodName` and should be called with self.
		@example
			local Vehicle = dash.class("Vehicle", function(wheelCount) return 
				{
					speed = 0,
					wheelCount = wheelCount
				}
			end)
			-- Let's define a static private function to generate a unique id for each vehicle.
			function Vehicle._getNextId()
				Vehicle._nextId = Vehicle._nextId + 1
				return Vehicle._nextId
			end
			Vehicle._nextId = 0
			-- A general purpose init function may call other helper methods
			function Vehicle:_init()
				self.id = self:_generateId()
			end
			-- Assign an id to the new instance
			function Vehicle:_generateId()
				return dash.format("#{}: {} wheels", Vehicle._getNextId(), self.wheelCount)
			end
			-- Let's make a Car class which has a special way to generate ids
			local Car = Vehicle:extend("Vehicle", function()
				return Vehicle.constructor(4)
			end)
			-- Uses the super method to generate a car-specific id
			function Car:_generateId()
				self.id = dash.format("Car {}", Vehicle._generateId(self))
			end
			local car = Car.new()
			car.id --> "Car #1: 4 wheels"
	]]
	function Class:extend(name: string, constructor)
		local SubClass = class(name, constructor or Class.new)
		setmetatable(SubClass, {__index = self})
		return SubClass
	end

	--[[
		Return a string representation of the instance. By default this is the _name_ field (or the
		Class name if this is not defined), but the method can be overridden.
		@example
			local Car = class("Car", function(name)
				return {
					name = name
				}
			end)
			
			local car = Car.new()
			car:toString() --> 'Car'
			tostring(car) --> 'Car'
			print("Hello " .. car) -->> Hello Car
			local bob = Car.new("Bob")
			bob:toString() --> 'Bob'
			tostring(bob) --> 'Bob'
			print("Hello " .. bob) -->> Hello Bob
		@example
			local NamedCar = class("NamedCar", function(name)
				return {
					name = name
				}
			end)
			function NamedCar:toString()
				return "Car called " .. self.name
			end
			local bob = NamedCar.new("Bob")
			bob:toString() --> 'Car called Bob'
			tostring(bob) --> 'Car called Bob'
			print("Hello " .. bob) -->> Hello Car called Bob
	]]
	function Class:toString()
		return self.name
	end

	--[[
		Returns `true` if `self` is considered equal to _other_. This replaces the `==` operator
		on instances of this class, and can be overridden to provide a custom implementation.
	]]
	function Class:equals(other)
		return rawequal(self, other)
	end

	--[[
		Returns `true` if `self` is considered less than  _other_. This replaces the `<` operator
		on instances of this class, and can be overridden to provide a custom implementation.
	]]
	function Class:__lt(other)
		throwNotImplemented({
			methodName = "__lt",
			className = name
		})	
	end

	--[[
		Returns `true` if `self` is considered less than or equal to _other_. This replaces the
		`<=` operator on instances of this class, and can be overridden to provide a custom
		implementation.
	]]
	function Class:__le(other)
		throwNotImplemented({
			methodName = "__le",
			className = name
		})	
	end

	function Class:__add()
		throwNotImplemented({
			methodName = "__add",
			className = name
		})	
	end
	function Class:__sub()
		throwNotImplemented({
			methodName = "__sub",
			className = name
		})	
	end
	function Class:__mul()
		throwNotImplemented({
			methodName = "__mul",
			className = name
		})	
	end
	function Class:__div()
		throwNotImplemented({
			methodName = "__div",
			className = name
		})	
	end
	function Class:__mod()
		throwNotImplemented({
			methodName = "__mod",
			className = name
		})	
	end

	return Class
end

return class