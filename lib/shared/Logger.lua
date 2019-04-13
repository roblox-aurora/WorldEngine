local Object = require(script.Parent.Object)
local t = require(script.Parent.t)
local Logger = Object:Extend("Logger")

local LogVerbosity = Object:Enum("LogVerbosity", {"Errors", "Warnings", "Info", "Verbose"})
local LogPrefix = Object:Enum("LogPrefix", {"None", "Script", "ScriptFullName"})

local loggerConstructorArgs =
	t.interface(
	{
		prefix = t.optional(t.union(t.string, LogPrefix.instance)),
		verbosity = t.optional(LogVerbosity.instance),
		enableFormatting = t.optional(t.boolean),
		zeroBasedIndexing = t.optional(t.boolean)
	}
)

Logger.Prefix = LogPrefix
Logger.Verbosity = LogVerbosity

function Logger:constructor(options)
	options = options or {}

	assert(loggerConstructorArgs(options))
	self.prefix = options.prefix or LogPrefix.Script
	self.verbosity = options.verbosity or LogVerbosity.Warnings
	self.zeroBasedIndexing = options.zeroBasedIndexing or false

	local formatterEnabled
	if (options.formatterEnabled ~= nil) then
		formatterEnabled = options.formatterEnabled
	else
		formatterEnabled = true
	end
	self.formatterEnabled = formatterEnabled
end

function Logger:_getPrefix()
	local prefix = self.prefix
	local caller = getfenv(3).script
	if prefix == LogPrefix.ScriptFullName then
		return "[" .. caller:GetFullName() .. "]"
	elseif prefix == LogPrefix.Script then
		return "[" .. caller.Name .. "]"
	elseif t.string(prefix) then
		return "[" .. prefix .. "]"
	else
		return ""
	end
end

function Logger:_parseVariable(source, variable, value)
	local _parseVariableArg = t.tuple(t.string, t.union(t.string, t.number), t.any)
	assert(_parseVariableArg(source, variable, value))
	local newSource = source:gsub(
		"{(.-)}",
		function(argl)
			local formatter = argl:match("^" .. variable .. ":(.-)$")
			if (argl:match("^" .. variable .. "$")) then
				return tostring(value)
			elseif (formatter) then
				local basicFormat = formatter:match("^[qQJji]$")
				local numericValue, numericFormat = formatter:match("^(%-*%d*)([difXx])$")
				-- Quote mode
				if (basicFormat) then
					if (basicFormat:lower() == "q") then
						return '"' .. tostring(value) .. '"'
					elseif (basicFormat:lower() == "j") then
						return game:GetService("HttpService"):JSONEncode(value)
					elseif (basicFormat == "i") then
						return string.format("%d", value)
					end
				elseif (numericFormat) then
					if numericFormat == "i" then
						local modifier = tonumber(numericValue)
						local num = tonumber(value)
						if (modifier == 1) then
							num = math.floor(num + 0.5)
						elseif (modifier == -1) then
							num = math.ceil(num - 0.5)
						end

						return tostring(num)
					end

					local mid = (numericValue ~= "" and numericValue or "1")
					local suffix = numericFormat
					local prefix = "%."

					if (numericFormat == "d") then
						prefix = "%0"
						suffix = "d"
					end

					local computedValue = string.format(prefix .. mid .. suffix, tonumber(value) or 0)
					return computedValue
				else
					error(
						("Invalid formatter at index %s: %s"):format(
							(type(variable) == "number" and "#" .. tostring(variable) or "`" .. tostring(variable) .. "`"),
							source
						)
					)
				end
			end
		end
	)

	return newSource
end

local FORMAT_TYPES = t.tuple(t.string, t.array(t.any))
function Logger:Format(formatString, ...)
	local zeroBased = self.zeroBasedIndexing
	local args = {...}
	assert(FORMAT_TYPES(formatString, args))

	if self.formatterEnabled then
		for index, arg in next, args do
			formatString = self:_parseVariable(formatString, zeroBased and index - 1 or index, arg)
		end

		formatString:gsub(
			"{(.-)}",
			function(value)
				error(
					("Invalid formatter id %s: %s"):format(
						(value:match("%d+") and "#" .. tostring(value) or "`" .. tostring(value) .. "`"),
						formatString
					)
				)
			end
		)
	end

	return formatString
end

local FORMAT_TABLE_TYPES = t.tuple(t.string, t.keys(t.string))
function Logger:FormatTable(formatString, tbl)
	assert(FORMAT_TABLE_TYPES(formatString, tbl))

	if self.formatterEnabled then
		for index, arg in next, tbl do
			formatString = self:_parseVariable(formatString, index, arg)
		end

		formatString:gsub(
			"{(.-)}",
			function(value)
				error(
					("Invalid formatter id %s: %s"):format(
						(value:match("%d+") and "#" .. tostring(value) or "`" .. tostring(value) .. "`"),
						formatString
					)
				)
			end
		)
	end

	return formatString
end

-- luacov: disable
function Logger:Info(formatString, ...)
	if self.verbosity.Value < 3 then
		return
	end

	local output = ("%s %s"):format(self:_getPrefix(), self:Format(formatString, ...))

	print(output)
	return output
end

function Logger:Warn(formatString, ...)
	if self.verbosity.Value < 3 then
		return
	end

	local args = {...}
	if (#args > 0) then
		warn(self:_getPrefix(), self:Format(formatString, ...))
	else
		warn(self:_getPrefix(), formatString)
	end
end

function Logger:AssertTrue(condition, formatString, ...)
	if not condition then
		error(self:getPrefix() .. " " .. self:Format(formatString, ...), 2)
	else
		return condition
	end
end

function Logger:Error(formatString, ...)
	error(self:getPrefix() .. " " .. self:Format(formatString, ...), 2)
end


local RunService = game:GetService("RunService")
local Default =
	RunService:IsStudio() and
	Logger.new(
		{
			prefix = LogPrefix.ScriptFullName,
			verbosity = LogVerbosity.Verbose
		}
	) or
	Logger.new()

-- luacov: enable

return setmetatable(
	{
		new = Logger.new,
		Default = Default
	},
	{
		__index = Default,
		__newindex = function(self, index, value)
			assert(Logger:Is(value), "Only type `Logger` can be assigned as a member of Logger.")
			rawset(self, index, value)
		end
	}
)
