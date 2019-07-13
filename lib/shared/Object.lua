local Object = {}
Object.__index = Object
Object.__newindex = function(self)
	error("Cannot assign value to " .. tostring(self), 2)
end
Object.__tostring = function()
	return "ObjectFactory"
end
local registry = {}

function Object.Get(_, name)
	return (assert(registry[name], tostring(name) .. " is not in the registry!"))
end

-- luacov: disable
local function symbol(name)
	local self = newproxy(true)
	local wrappedName = ("Symbol(%s)"):format(name)
	getmetatable(self).__tostring = function()
		return wrappedName
	end

	return self
end
-- luacov: enable

local ID_CLASS = symbol("Class")
local ID_INHERITANCE = symbol("Inheritance")
local ID_INSTANCE = symbol("Instance")
local ID_PARENT_CLASS = symbol("ParentClass")
local ID_CLASS_NAME = symbol("ClassName")
local ID_SEALED = symbol("SealedModifier")
local ID_REF = symbol("Ref")

--- Creates a sealed enum class
function Object.Enum(_, name, values)
	local enum = Object:Extend(name, {sealed = true})
	function enum:constructor(_name, _value)
		self.Name = _name
		self.Value = _value
	end

	function enum:tostring()
		return "Enum[" .. name .. "@" .. self.Name .. "]"
	end

	for idx, value in next, values do
		enum[value] = enum.new(value, idx)
	end

	enum.new = nil

	return enum
end

-- Used to check, like Rbx:IsA
local function class_IsType(object, className)
	local meta = getmetatable(object)
	if (meta[ID_INSTANCE]) then
		for _, baseClass in next, meta[ID_CLASS][ID_INHERITANCE] do
			if (baseClass[ID_CLASS_NAME] == className) then
				return true
			end
		end

		return false
	else
		error("Cannot call IsA on a class type", 2)
	end
end

local function class_Is(self, value)
	local selfmeta = getmetatable(self)
	local meta = type(value) == "table" and getmetatable(value)

	if not selfmeta or selfmeta[ID_INSTANCE] then
		error("`Is` must be called on a class!", 2)
	end

	if meta and meta[ID_INSTANCE] then
		return value:IsType(self[ID_CLASS_NAME])
	else
		return false
	end
end

-- Used to pass inheritance
local function class_super(_class, obj, ...)
	-- luacov: disable
	if (type(obj) ~= "table") then
		error("First argument of super must be an object!", 2)
	end

	if (_class == getmetatable(obj).__index) then
		error("Call 'super' on the base class rather than the same class!", 2)
	end
	-- luacov: enable

	if type(_class.constructor) == "function" then
		_class.constructor(obj, ...)
	end
end

local function throwOnNew()
	error("Cannot call new on object instance", 2)
end -- prevent creating object from another object

local function errorf(fmt, ...)
	error((fmt):format(...), 3)
end

local Destroyed = {
	__index = function()
		error("Attempt to index destroyed object", 2)
	end,
	__newindex = function()
		error("Attempt to set value on destroyed object", 2)
	end,
	__tostring = function()
		return "DestroyedObject"
	end
}

function Object:Destroy()
	-- luacov: disable
	if self == Object then
		error("Cannot call destroy on ObjectFactory!", 2)
	end
	-- luacov: enable

	local meta = getmetatable(self)
	if meta[ID_INSTANCE] then
		-- If the user wants to do their own cleanup, they can! :-)
		if type(self.destructor) == "function" then
			self:destructor()
		end

		for index in next, self do
			-- Set child values to nil
			self[index] = nil
		end

		setmetatable(self, Destroyed)
	else
		error("Cannot call destroy on " .. tostring(self))
	end
end

local refId = 0

--- Class:Extend(str) for class extending, default is Object:Extend( ) for base classes
function Object:Extend(name, options)
	refId = refId + 1
	assert(type(name) == "string")
	assert(type(options) == "table" or options == nil)

	options = options or {}
	local sealed = options.sealed or false
	local abstract = options.abstract or false
	local mutators = options.mutators or false
	local operators = options.operators or false

	if (registry[name]) then
		errorf("[Object] Duplicate class `%s`", name)
	end

	if sealed and abstract then
		errorf("[Object] %s cannot be both sealed and abstract.", name)
	end

	if (self[ID_SEALED]) then
		errorf("[Object] Cannot extend %s from sealed class %s - as it sealed.", name, self[ID_CLASS_NAME])
	end

	local super = {
		__index = self,
		__tostring = function(self)
			return "[class " .. name .. "]"
		end
	}

	local class = {}
	class.__index = class
	class[ID_REF] = refId
	class[ID_CLASS_NAME] = name
	class.ClassName = name
	class[ID_PARENT_CLASS] = super
	class[ID_INHERITANCE] = {class, unpack(self[ID_INHERITANCE] or {})}

	if (sealed) then
		class[ID_SEALED] = true
	end

	setmetatable(class, super)

	class.Is = class_Is
	class.IsType = class_IsType
	class.super = class_super

	if mutators then
		class.get = {}
		class.set = {}
	end

	-- static instance(value: unknown): value is {ClassName}
	function class.instance(value)
		local err = "Expected %s got %s"
		local meta = type(value) == "table" and getmetatable(value)

		if meta then
			local metaclass = meta[ID_CLASS]
			if metaclass then
				return value:IsType(name), err:format(name, metaclass[ID_CLASS_NAME])
			elseif value[ID_CLASS_NAME] then
				return false, "Expected " .. name .. " got class " .. value[ID_CLASS_NAME]
			else
				return false, "Expected " .. name .. " got " .. tostring(value)
			end
		else
			return false, err:format(name, type(value))
		end
	end

	-- Handler for X.new(...) - Calls X.constructor(...) internally
	if not abstract then
		function class.new(...)
			refId = refId + 1
			local allowNewProperties = true
			local meta = {
				[ID_REF] = refId,
				[ID_PARENT_CLASS] = super,
				[ID_CLASS] = class,
				-- __newindex = ,
				__index = class,
				[ID_INSTANCE] = true,
				__tostring = function(self)
					if type(self.tostring) == "function" then
						return self:tostring()
					else
						return name .. ": " .. string.format("%.16X", getmetatable(self)[ID_REF])
					end
				end
			}

			-- luacov: disable
			-- TODO: Write tests
			if operators then
				meta.__add = class.add or nil
				meta.__sub = class.sub or nil
				meta.__mul = class.mul or nil
				meta.__div = class.div or nil
				meta.__mod = class.mod or nil
				meta.__lt = class.lessthan or nil
				meta.__gt = class.greater or nil
				meta.__eq = class.equal or nil
			end
			-- luacov: enable

			-- experimental mutators
			-- luacov: disable
			-- TODO: Write tests
			if mutators then
				meta.__newindex = function(self, index, value)
					local setterGlobal = rawget(class, "set")
					local setterFn = type(setterGlobal) == "table" and rawget(setterGlobal, tostring(index))
					if allowNewProperties then
						rawset(self, index, value)
					elseif type(setterGlobal) == "function" then
						setterGlobal(self, index, value)
					elseif type(setterFn) == "function" then
						setterFn(self, value)
					else
						error("Cannot assign new property outside of constructor: " .. tostring(index), 2)
					end
				end
				meta.__index = function(self, index)
					local getterGlobal = rawget(class, "get")
					local getterFn = type(getterGlobal) == "table" and rawget(getterGlobal, tostring(index))
					local child = type(getterGlobal) == "function" and getterGlobal(self, index) or rawget(self, index)
					if child then
						return child
					elseif type(getterFn) == "function" then
						return getterFn(self)
					else
						return class[index]
					end
				end
			end
			-- luacov: enable

			local obj = setmetatable({}, meta)
			-- obj.new = throwOnNew

			if type(class.constructor) == "function" then
				class.constructor(obj, ...)
			end

			allowNewProperties = false

			return obj
		end
	else
		function class.new()
			errorf("[%s.new] Cannot create type defined as abstract", name)
		end
	end

	registry[name] = class
	return class
end

-- luacov: disable
function Object.typeIs(t)
	warn("[Object.typeIs] typeIs is deprecated, use Class.instance instead.")
	print(debug.traceback())

	if (type(t) == "table") then
		return function(value)
			local meta = getmetatable(value)
			if not meta then
				return false, "expected `" .. t[ID_CLASS_NAME] .. "` got  `" .. typeof(value) .. "`"
			end

			return t:Is(value), "expected `" .. t[ID_CLASS_NAME] .. "` got  `" .. meta[ID_CLASS][ID_CLASS_NAME] .. "`"
		end
	else
		return function(value)
			local meta = getmetatable(value)
			if (meta and meta[ID_INSTANCE]) then
				return value:IsType(t), "expected `" .. t .. "` got `" .. meta[ID_CLASS_NAME] .. "`"
			end

			return false, "expected `" .. t .. "` got `" .. typeof(value) .. "`"
		end
	end
end
-- luacov: enable

return setmetatable({}, Object)
