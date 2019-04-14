local split = string.split or function(self, delimiter)
		local result = {}
		local from = 1
		local delim_from, delim_to = string.find(self, delimiter, from)
		while delim_from do
			table.insert(result, string.sub(self, from, delim_from - 1))
			from = delim_to + 1
			delim_from, delim_to = string.find(self, delimiter, from)
		end
		table.insert(result, string.sub(self, from))
		return result
	end

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vars = {
	["local"] = RunService:IsServer() and ServerStorage or ReplicatedStorage,
	core = (RunService:IsServer() or __LEMUR__) and ServerScriptService:FindFirstChild("WorldEngine"),
	corelib = ReplicatedStorage:FindFirstChild("WorldEngine")
}

local function modulepath(array, module)
	local target = require(module)
	for _, part in next, array do
		-- assert(target[part], "Path " .. table.concat(array, ".") .. " is an invalid Lua path for " .. module:GetFullName())
		target = target[part]
		if not target then
			return
		end
	end

	return target
end

local function path(array, opts)
	local relativeTo = opts.relativeTo or game
	local homePath = opts.homePath
	local throws
	if opts.throws ~= nil then
		throws = opts.throws
	else
		throws = true
	end

	local first = array[1]
	if (first and first:match("%@(.-)")) then
		-- elseif vars[first] then
		-- 	relativeTo = vars[first]
		-- 	table.remove(array, 1)
		relativeTo = assert(vars[first:sub(2)], "Invalid variable: " .. first)
		table.remove(array, 1)
	elseif (first == "~") then
		local isClient = not RunService:IsServer()
		relativeTo = homePath or (isClient and game:GetService("ReplicatedStorage") or game:GetService("ServerScriptService"))
		table.remove(array, 1)
	elseif (first == "") then -- root
		relativeTo = game
		table.remove(array, 1)
	elseif (first == ".") then -- remove script relativity.
		table.remove(array, 1)
	end

	local target
	if type(relativeTo) == "string" then
		target = game:GetService(relativeTo)
	else
		target = relativeTo
	end

	for _, part in next, array do
		if part == ".." then
			target = target.Parent
		else
			local instance = target:FindFirstChild(part, opts.findRelative)
			if instance then
				target = instance
			elseif throws then
				error(("%s is not a valid member of %s"):format(part, target:GetFullName()), 2)
			end
		end
	end

	return target
end

local MultiImport = {}
MultiImport.__index = MultiImport
function MultiImport:from(relativePath)
	local imports = {}
	local parent =
		path(
		split(relativePath, "/"),
		{
			relativeTo = self.relativeTo
		}
	)

	local isModule = parent and parent:IsA("ModuleScript")

	for _, item in next, self.imports do
		local target =
			(assert(
			path(split(item, "/"), {relativeTo = parent, throws = false}) or (isModule and modulepath(split(item, "."))),
			item .. " is not a valid FilePath or LuaPath relative to " .. tostring(relativePath)
		))
		if (typeof(target) == "Instance") then
			if target:IsA("ModuleScript") then
				table.insert(imports, require(target))
			else
				error(("[import] Invalid import: %s (%s)"):format(item, target.ClassName), 3)
			end
		else
			table.insert(imports, target)
		end
	end

	return unpack(imports)
end

local function import(value, relativeTo, overrides)
	if type(value) == "table" then -- Handle multi-import
		return setmetatable(
			{
				imports = value,
				relativeTo = relativeTo,
				overrides = overrides
			},
			MultiImport
		)
	end
	if typeof(value) == "Instance" then
		local result = require(value)
		if type(result) == "table" and result.default then
			return result.default
		else
			return result
		end
	elseif type(value) == "string" then
		local isRelativeImport = value:match("^[%.]+/")
		relativeTo = relativeTo or (isRelativeImport and getfenv(3).script or vars.corelib)
		if not relativeTo then
			-- luacov: ignore
			error("Invalid relativeTo in import")
		end

		overrides = overrides or {}

		local pathRel = split(value, "/")

		local result =
			path(
			pathRel,
			{
				homePath = overrides.homePath,
				relativeTo = relativeTo,
				findRelative = not isRelativeImport
			}
		)
		if result:IsA("ModuleScript") then
			if overrides.rawImport then
				return result
			else
				result = require(result)
				if type(result) == "table" and result.default then
					return result.default -- allow default imports
				else
					return result
				end
			end
		else
			error(("[import] Invalid import: %s (%s)"):format(value, result.ClassName), 2)
		end
	end
end
-- luacov: disable
-- variable discovery
local extraVarsModule = ReplicatedStorage:FindFirstChild(".imports", true)
if (extraVarsModule and extraVarsModule:IsA("ModuleScript")) then
	local extraVars = require(extraVarsModule)
	assert(typeof(extraVars) == "table")
	for name, value in next, extraVars do
		assert(typeof(value) == "Instance")
		vars[name] = value
	end
end

local prototype = {}

if (__LEMUR__) then
	function prototype.lemur(isServer)
		if not __LEMUR__ then
			error("`import.Test` can only be used by Lemur.", 2)
		end

		return function(p, r)
			if isServer then
				local value = import(p, r, {rawImport = true, homePath = ServerScriptService})
				print("[Import(Server)] Test import: ", ("%s (%s)"):format(p, value:GetFullName()))
				return value, value:GetFullName()
			else
				local value = import(p, r, {rawImport = true})
				print("[Import(Client)] Test import: ", ("%s (%s)"):format(p, value:GetFullName()))
				return value, value:GetFullName()
			end
		end
	end
end

function prototype.shared(relativePath)
	return import(relativePath, ReplicatedStorage)
end

function prototype.library(relativePath)
	return import(relativePath, ReplicatedStorage:WaitForChild("WorldEngine"))
end

function prototype.server(relativePath)
	return import(relativePath, ServerScriptService)
end

function prototype.relative(relativePath)
	return import(relativePath, getfenv(2).script)
end

local function importNSVariable(self, name)
	local value = vars[name]
	if value then
		return function(_, relativePath)
			return import(relativePath, value)
		end
	else
		error(tostring(name) .. " is not a valid member of import.prototype", 2)
	end
end

return setmetatable(
	prototype,
	{
		__call = function(_, ...)
			return import(...)
		end, -- alias: import.relative
		__index = importNSVariable
	}
)
-- luacov: enable
