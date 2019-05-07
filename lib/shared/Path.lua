local function pathParser(str, allowDot)
	assert(type(str) == "string")
	local parts = {}
	local part = ""
	local isSub = false
	local isEscaped = false
	local index = 1
	local SPLIT_OP = "/"
	local DOT_OP = "."
	local ESCAPE_OP = "%"
	local SUB_OP_OPEN = "{"
	local SUB_OP_CLOSE = "}"

	while index <= #str do
		local char = str:sub(index, index)

		if (char == SPLIT_OP or (char == DOT_OP and allowDot)) and not isSub and not isEscaped then
			table.insert(parts, part)
			part = ""
		elseif char == ESCAPE_OP then
			isEscaped = true
		elseif char == SUB_OP_OPEN and not isEscaped then
			if not isSub then
				isSub = true
			end
		elseif char == SUB_OP_CLOSE and isSub and not isEscaped then
			isSub = false
		else
			part = part .. char
			isEscaped = false
		end

		index = index + 1
	end

	if part ~= "" then
		table.insert(parts, part)
	end

	return parts
end

local function strtrim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function listParser(str)
	local SPLIT_OP = ","

	local index = 1
	local part = ""
	local parts = {}
	while index <= #str do
		local char = str:sub(index, index)

		if char == SPLIT_OP or index > #str then
			table.insert(parts, strtrim(part))
			part = ""
		else
			part = part .. char
		end
		index = index + 1
	end

	if part ~= "" then
		table.insert(parts, strtrim(part))
	end

	return parts
end

local RunService = game:GetService("RunService")
local IS_SERVER = RunService:IsServer()

local function path(fullPath, opts)
	local modules = opts.modules
	local vars = opts.variables
	local homePath = opts.homePath

	if type(fullPath) == "string" then
		fullPath = pathParser(fullPath) --split(fullPath, "/")
	end

	local relativeTo = opts.relativeTo or game

	local first = fullPath[1]
	if (first and vars and first:match("%@(.-)")) then
		relativeTo = assert(vars[first:sub(2)], "Invalid variable: " .. first)
		table.remove(fullPath, 1)
	elseif modules and first:match("^([A-z][A-z0-9]+)$") and modules[first] then
		relativeTo = modules[first]
		table.remove(fullPath, 1)
	elseif (first == "~") then
		relativeTo = homePath
		table.remove(fullPath, 1)
	elseif (first == "") then -- root
		relativeTo = game
		table.remove(fullPath, 1)
	elseif (first == ".") then -- remove script relativity.
		table.remove(fullPath, 1)
	end

	local target
	if type(relativeTo) == "string" then
		target = game:GetService(relativeTo)
	else
		target = relativeTo
	end

	local stack = {target.Name}
	local mode = "instance"
	local strict = true

	for i, part in next, fullPath do
		if part == ".." and mode == "instance" then
			target = target.Parent
			table.insert(stack, target.Name)
		elseif part == "#!" and mode == "instance" then -- allow LuaPathResolve
			-- elseif part:match("{.*}") then
			-- e.g. /ReplicatedStorage/MyModule/!#/MyFunction would be like require(ReplicatedStorage.MyModule).MyFunction
			target = require(target)
			strict = true
			mode = "lua"
		elseif part == "#?" and mode == "instance" then
			target = require(target)
			strict = false
			mode = "lua"
		elseif part == "*#!" and i == #fullPath and mode == "instance" then
			local values = {}
			for _, child in pairs(target:GetChildren()) do
				if child:IsA("ModuleScript") then
					values[child.Name] = require(child)
				end
			end
			return values
		elseif part == "*" and i == #fullPath then
			-- /ReplicatedStorage/MyModule/!#/MyTable/* - returns unpacked table, or gets children of instance
			local targetType = typeof(target)
			if targetType == "Instance" then
				return target:GetChildren()
			elseif targetType == "table" then
				return unpack(target)
			else
				return target
			end
		else
			if typeof(target) == "Instance" then
				local instance = IS_SERVER and target:FindFirstChild(part, opts.findRelative) or target:WaitForChild(part, 10)
				if instance then
					target = instance
					table.insert(stack, target.Name)
				else
					error(("%s is not a valid member of %s"):format(part, target:GetFullName()), 2)
				end
			elseif typeof(target) == "table" then
				local value = target[part]
				if value then
					table.insert(stack, part)
					target = value
				else
					if strict then
						error(("%s is not a valid path relative to %s"):format(part, table.concat(stack, "/")), 2)
					else
						return nil
					end
				end
			else
				error(
					"Cannot resolve (" ..
						table.concat(fullPath, "/") .. ") from (" .. type(target) .. ") " .. table.concat(stack, "/") .. ""
				)
			end
		end
	end

	return target, stack
end

return {
	get = path,
	parse = pathParser,
	parseList = listParser
}
