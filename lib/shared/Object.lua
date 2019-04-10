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

local function symbol(name)
	local self = newproxy(true)
	local wrappedName = ("Symbol(%s)"):format(name)
	getmetatable(self).__tostring = function()
		return wrappedName
	end

	return self
end

local ID_CLASS = symbol("Class")
local ID_INHERITANCE = symbol("Inheritance")
local ID_INSTANCE = symbol("Instance")
local ID_PARENT_CLASS = symbol("ParentClass")
local ID_CLASS_NAME = symbol("ClassName")
local ID_SEALED = symbol("SealedModifier")

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

--- Class:Extend(str) for class extending, default is Object:Extend( ) for base classes
function Object:Extend(name, options)
	assert(type(name) == "string")
	assert(type(options) == "table" or options == nil)

	options = options or {}
	local sealed = options.sealed or false
	local abstract = options.abstract or false
	local mutators = options.mutators or false

	if (registry[name]) then
		error("Duplicate class `" .. tostring(name) .. "`.", 2)
	end

	if (self[ID_SEALED]) then
		error("Cannot extend sealed class!", 2)
	end

	local super = {
		__index = self,
		__tostring = function(self)
			return "class " .. name
		end
	}

	local class = {}
	class.__index = class
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

	-- Handler for X.new(...) - Calls X.constructor(...) internally
	if not abstract then
		function class.new(...)
			local allowNewProperties = true
			local meta = {
				[ID_PARENT_CLASS] = super,
				[ID_CLASS] = class,
				-- __newindex = ,
				__index = class,
				[ID_INSTANCE] = true,
				__tostring = function(self)
					if type(self.tostring) == "function" then
						return self:tostring()
					else
						return "Object@" .. tostring(class)
					end
				end
			}

			-- experimental mutators
			if mutators then
				meta.__newindex = function(self, index, value)
					local setterGlobal = rawget(class, "set")
					local setterFn = rawget(class, "Set" .. tostring(index))
					if allowNewProperties then
						rawset(self, index, value)
					elseif setterGlobal then
						setterGlobal(self, index, value)
					elseif type(setterFn) == "function" then
						setterFn(self, value)
					else
						error("Cannot assign new property outside of constructor: " .. tostring(index), 2)
					end
				end
				meta.__index = function(self, index)
					local getterGlobal = rawget(class, "get")
					local getterFn = rawget(class, "Get" .. tostring(index))
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

			local obj = setmetatable({}, meta)
			obj.new = throwOnNew

			if type(class.constructor) == "function" then
				class.constructor(obj, ...)
			end

			allowNewProperties = false

			return obj
		end
	else
		function class.new()
			error("Cannot create abstract type '" .. tostring(name) .. "'", 2)
		end
	end

	registry[name] = class
	return class
end

-- luacov: disable
function Object.typeIs(t)
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
