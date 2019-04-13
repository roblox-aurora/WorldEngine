local table_remove = table.remove
local table_concat = table.concat
local table = setmetatable({}, {__index = table})

function table.map(t, mapFn)
	assert(type(t) == "table", "Argument #1 to table.map - expected table got " .. type(t))
	assert(type(mapFn) == "function", "Argument #2 to table.map - expected function got " .. type(mapFn))

	local mapped = {}

	for i = 1, #t do
		local nextValue = mapFn(t[i], i)
		table.insert(mapped, nextValue)
	end

	return mapped
end

function table.filter(t, filterFn)
	assert(type(t) == "table", "Argument #1 to table.filter - expected table got " .. type(t))
	assert(type(filterFn) == "function", "Argument #2 to table.filter - expected function got " .. type(filterFn))

	local filtered = {}
	for i = 1, #t do
		local value = t[i]
		if filterFn(value) then
			table.insert(filtered, value)
		end
	end

	return filtered
end

function table.find(t, findFn)
	assert(type(t) == "table", "Argument #1 to table.find - expected table got " .. type(t))
	assert(type(findFn) == "function", "Argument #2 to table.find - expected function got " .. type(findFn))

	for i = 1, #t do
		local value = t[i]
		if findFn(value, i) then
			return value, i
		end
	end
end

local indent = 0
local function table_to_str(t, prettyPrint)
	local values = {}
	local char = type(prettyPrint) == "string" and prettyPrint or "\t"
	for k, value in next, t do
		local isNumericKey = type(k) == "number"

		if type(value) == "table" then
			indent = indent + 1
			value = table_to_str(value, prettyPrint)
			indent = indent - 1
		elseif type(value) == "function" then
			value = "<function()>"
		elseif type(value) == "userdata" then
			value = "<userdata: " .. tostring(value) .. ">"
		end

		table.insert(
			values,
			(prettyPrint and "%s" .. char .. "%s = %s" or "%s%s = %s"):format(
				prettyPrint and (char):rep(indent) or "",
				isNumericKey and "[" .. tostring(k) .. "]" or k,
				value
			)
		)
	end

	return "{" ..
		(prettyPrint and "\n" or "") ..
			table_concat(values, prettyPrint and ",\n" or ", ") .. (prettyPrint and "\n" .. (char):rep(indent) or "") .. "}"
end

function table.tostring(t, pretty)
	return table_to_str(t, pretty)
end

-- Improved table.concat
function table.concat(t, sep)
	local values = {}
	for i = 1, #t do
		local value = t[i]
		if type(value) == "table" then
			table.insert(values, "[ " .. table.concat(value, sep) .. " ]")
		else
			table.insert(values, tostring(value))
		end
	end

	return table_concat(values, sep)
end

-- Improved table.remove
function table.remove(t, query)
	if type(query) == "number" then
		return table_remove(t, query)
	elseif type(query) == "function" then
		for index, value in next, t do
			if (query(value, index)) then
				table_remove(t, index)
			end
		end
	else
		for index, value in next, t do
			if (value == query) then
				return table_remove(t, index)
			end
		end
	end
end

function table.join(...)
	local tables = {...}
	local newTable = {}
	for _, t in next, tables do
		assert(type(t) == "table")
		for k, v in next, t do
			if (type(k) == "string") then
				newTable[k] = v
			else
				table.insert(newTable, v)
			end
		end
	end
	return newTable
end

return table