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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local vars = {
	engine = ServerScriptService:FindFirstChild("WorldEngine"),
	lib = ReplicatedStorage:FindFirstChild("WorldEngine")
}

local function path(array, opts)
	local relativeTo = opts.relativeTo or game
	local homePath = opts.homePath

	local first = array[1]
	if (first and first:match("%$(.-)")) then
		relativeTo = assert(vars[first:sub(2)], "Invalid variable: " .. first)
		table.remove(array, 1)
	elseif (first == "~") then
		local isClient = not RunService:IsServer()
		relativeTo = homePath or (isClient and game:GetService("ReplicatedStorage") or game:GetService("ServerScriptService"))
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
			target = getfenv(1).script.Parent
		else
			local instance = target:FindFirstChild(part)
			if instance then
				target = instance
			else
				error(("%s is not a valid member of %s"):format(part, target:GetFullName()), 2)
			end
		end
	end

	return target
end

local function import(value, relativeTo, overrides)
	overrides = overrides or {}
	if typeof(value) == "Instance" then
		return require(value)
	elseif type(value) == "string" then
		local pathRel = split(value, "/")

		local result =
			path(
			pathRel,
			{
				homePath = overrides.homePath,
				relativeTo = relativeTo or (RunService:IsServer() and "ServerScriptService" or "ReplicatedStorage")
			}
		)
		if result:IsA("ModuleScript") then
			return overrides.rawImport and result or require(result)
		else
			error(("[import] Invalid import: %s (%s)"):format(value, result.ClassName), 2)
		end
	end
end

local Import = {
	Server = "ServerScriptService",
	Shared = "ReplicatedStorage",
	Client = nil,
	Test = function(isServer)
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
}
Import.__index = Import
-- luacov: disable
Import.__call = function(_, ...)
	return import(...)
end

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
-- luacov: enable

return setmetatable({}, Import)
