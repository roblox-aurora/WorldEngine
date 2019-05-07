local split = string.split or function(self, delimiter)
		if type(self) ~= "string" then
			error("Expected string got " .. typeof(self))
		end

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
local IS_SERVER = RunService:IsServer()
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Path = require(script.Parent.Path)

local modules = {}

local vars = {
	["local"] = IS_SERVER and ServerStorage or ReplicatedStorage,
	core = (IS_SERVER or __LEMUR__) and ServerScriptService:FindFirstChild("WorldEngine"),
	corelib = ReplicatedStorage:FindFirstChild("WorldEngine")
}

local function strtrim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function path(array, opts)
	if type(array) == "string" then
		array = Path.parse(array)
	end

	print("PathGet", table.concat(array, "/"))

	-- local homePath = opts.homePath

	-- local first = array[1]
	-- if (first and first:match("%@(.-)")) then
	-- 	opts.relativeTo = assert(vars[first:sub(2)], "Invalid variable: " .. first)
	-- 	table.remove(array, 1)
	-- elseif first:match("^([A-z][A-z0-9]+)$") and modules[first] then
	-- 	opts.relativeTo = modules[first]
	-- 	table.remove(array, 1)
	-- elseif (first == "~") then
	-- 	local isClient = not RunService:IsServer()
	-- 	opts.relativeTo =
	-- 		homePath or (isClient and game:GetService("ReplicatedStorage") or game:GetService("ServerScriptService"))
	-- 	table.remove(array, 1)
	-- elseif (first == "") then -- root
	-- 	opts.relativeTo = game
	-- 	table.remove(array, 1)
	-- elseif (first == ".") then -- remove script relativity.
	-- 	table.remove(array, 1)
	-- end

	local isClient = not RunService:IsServer()

	opts.homePath =
		opts.homePath or (isClient and game:GetService("ReplicatedStorage") or game:GetService("ServerScriptService"))
	opts.variables = vars
	opts.modules = modules
	return Path.get(array, opts)
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

	for _, item in next, self.imports do
		local target = path(split(item, "/"), {relativeTo = parent})
		if target:IsA("ModuleScript") then
			table.insert(imports, require(target))
		else
			error(("[import] Invalid import: %s (%s)"):format(item, target.ClassName), 3)
		end
	end

	return unpack(imports)
end

local currentlyLoading = {}
local function import_internal(value, relativeTo, overrides)
	local result = nil

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
		-- luacheck: ignore
		result = require(value)
	elseif type(value) == "string" then
		local isRelativeImport = value:match("^[%.]+/")
		relativeTo = relativeTo or (isRelativeImport and getfenv(4).script or vars.corelib)
		if not relativeTo then
			-- luacov: disable
			error("Invalid relativeTo in import")
		-- luacov: enable
		end

		overrides = overrides or {}

		result =
			result or
			path(
				value,
				{
					homePath = overrides.homePath,
					relativeTo = relativeTo,
					findRelative = not isRelativeImport
				}
			)

		local caller = getfenv(4).script or "commandBar"

		if typeof(result) == "Instance" then
			if result:IsA("ModuleScript") then
				if overrides.rawImport then
					return result
				else
					currentlyLoading[caller] = result
					local currentModule = result
					local depth = 0

					while currentModule do
						depth = depth + 1
						currentModule = currentlyLoading[currentModule]

						if currentModule == result then
							local str = currentModule.Name or "?"

							for _ = 1, depth do
								currentModule = currentlyLoading[currentModule]
								str = str .. " -> " .. currentModule.Name
							end

							error("Failed to import! Detected a circular dependency chain: " .. str, 2)
						end
					end

					result = require(result)

					if currentlyLoading[caller] == module then
						currentlyLoading[caller] = nil
					end

					return result
				end
			else
				error(("[import] Invalid import: %s (%s, IsA %s)"):format(value, result:GetFullName(), result.ClassName), 2)
			end
		else
			return result
		end
	end
end

local function import(value, relativeTo, overrides)
	if typeof(value) == "Instance" then
		return require(value)
	end

	if (type(value) == "string" and value:match("^([A-z0-9%.%-/@]+)$")) or type(value) == "table" then
		return import_internal(value, relativeTo, overrides)
	else
		local importList = {}
		local parts = Path.parseList(value)

		for _, part in next, parts do
			table.insert(importList, import_internal(part, relativeTo, overrides))
		end

		return unpack(importList)
	end
end

local function load_imports(module)
	assert(typeof(module) == "Instance" and module:IsA("ModuleScript"), "Imports declaration should be a ModuleScript!")

	local extraVars = require(module)
	assert(typeof(extraVars) == "table")
	for name, value in next, extraVars do
		assert(typeof(value) == "Instance", name .. " is not an instance")
		vars[name] = value
	end
end

-- luacov: disable
-- variable discovery

if (IS_SERVER) then
	local extraServerVarsModule = ServerScriptService:FindFirstChild(".imports", true)
	if (extraServerVarsModule and extraServerVarsModule:IsA("ModuleScript")) then
		load_imports(extraServerVarsModule)
	end
else
	local extraVarsModule = ReplicatedStorage:FindFirstChild(".imports", true)
	if (extraVarsModule and extraVarsModule:IsA("ModuleScript")) then
		load_imports(extraVarsModule)
	end
end

local function getModules(dir, mods)
	for _, modulePath in pairs(mods) do
		local module = path(split(strtrim(modulePath), "/"), {relativeTo = dir})
		modules[module.Name] = module
	end
end

local function findModuleDeclarations(dir)
	for _, child in pairs(dir:GetChildren()) do
		if (child:IsA("StringValue") and child.Name == "modules") then
			getModules(child.Parent, split(child.Value, "\n"))
		else
			findModuleDeclarations(child)
		end
	end
end

findModuleDeclarations(ReplicatedStorage)

local prototype = {}

if (__LEMUR__) then
	function prototype.lemur(isServer)
		if not __LEMUR__ then
			error("`import.Test` can only be used by Lemur.", 2)
		end

		return function(p, r)
			if isServer then
				local value = import(p, r, {rawImport = true, homePath = ServerScriptService})
				print("[Import(Server)] Test import: ", ("%s (%s)"):format(p, value and value:GetFullName() or "?"))
				return value, value and value:GetFullName() or "?"
			else
				local value = import(p, r, {rawImport = true})
				print(
					"[Import(Client)] Test import: ",
					("%s (%s)"):format(tostring(p), typeof(value) == "Instance" and value:GetFullName() or tostring(value))
				)
				return value, typeof(value) == "Instance" and value:GetFullName() or tostring(value)
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

function prototype.lazy(relativePath)
	local ref
	return setmetatable(
		{},
		{
			__index = function(self, index)
				if not ref then
					ref = import_internal(relativePath)
				end

				return ref[index]
			end
		}
	)
end

function prototype.async(relativePath, relativeTo, overrides)
	local Promise = require(script.Parent.Promise)
	return Promise.new(
		function(resolve, reject)
			Promise.spawn(
				function()
					local success, result = pcall(import, relativePath, relativeTo, overrides)
					if success then
						resolve(result)
					else
						reject(result)
					end
				end
			)
		end
	)
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
		__index = importNSVariable,
		__tostring = function()
			return "ImportSystem"
		end
	}
)
-- luacov: enable
