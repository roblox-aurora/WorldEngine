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

--- Class:Extend(str) for class extending, default is Object:Extend( ) for base classes
function Object:Extend(name, options)
	assert(type(name) == "string")
	assert(type(options) == "table" or options == nil)

	options = options or {}
	local sealed = options.sealed or false
	local abstract = options.abstract or false

	if (registry[name]) then
		error("Duplicate class `" .. tostring(name) .. "`.", 2)
	end

	if (self._sealed) then
		error("Cannot extend sealed class!", 2)
	end

	local super = {
		__index = self,
		__tostring = function(self)
			return name
		end
	}

	local class = {}
	class.__index = class
	class._className = name
	class._parentclass = super
	class._inheritance = {class, unpack(self._inheritance or {})}

	if (sealed) then
		class._sealed = true
	end

	setmetatable(class, super)

	-- Used to check, like Rbx:IsA
	function class.IsType(object, className)
		local meta = getmetatable(object)
		if (meta._instance) then
			for _, baseClass in next, meta._class._inheritance do
				if (baseClass._className == className) then
					return true
				end
			end

			return false
		else
			error("Cannot call IsA on a class type", 2)
		end
	end

	function class.Is(_self, value)
		local selfmeta = getmetatable(_self)
		local meta = type(value) == "table" and getmetatable(value)

		if not selfmeta or selfmeta._instance then
			error("`Is` must be called on a class!", 2)
		end

		if meta and meta._instance then
			return value:IsType(name)
		else
			return false
		end
	end

	-- Used to pass inheritance
	function class.super(_class, obj, ...)
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

	-- Handler for X.new(...) - Calls X.constructor(...) internally
	if not abstract then
		function class.new(...)
			local meta = {
				_base = super,
				_class = class,
				__index = class,
				_instance = true,
				__tostring = function(self)
					if type(self.tostring) == "function" then
						return self:tostring()
					else
						return "Object@" .. tostring(class)
					end
				end
			}

			local obj = setmetatable({}, meta)

			if type(class.constructor) == "function" then
				class.constructor(obj, ...)
			end

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
				return false, "expected `" .. t._className .. "` got  `" .. typeof(value) .. "`"
			end

			return t:Is(value), "expected `" .. t._className .. "` got  `" .. meta._class._className .. "`"
		end
	else
		return function(value)
			local meta = getmetatable(value)
			if (meta and meta._instance) then
				return value:IsType(t), "expected `" .. t .. "` got `" .. meta._className .. "`"
			end

			return false, "expected `" .. t .. "` got `" .. typeof(value) .. "`"
		end
	end
end
-- luacov: enable

return setmetatable({}, Object)
