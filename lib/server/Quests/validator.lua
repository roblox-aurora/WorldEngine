local function uniqueIdValidator(value)
	local PATTERN = "^([a-z-]+)$"
	local MAX_LEN = 20
	local err = ("expected questId (e.g. quest-id) - maxLength: %d, pattern: %s"):format(MAX_LEN, PATTERN)
	return type(value) == "string" and (value:match(PATTERN) ~= nil) and #value <= 15, err
end

local function uniqueKey(reg)
	return function(value)
		return reg[value] == nil, "Duplicate key: " .. tostring(value)
	end
end

return {
	id = uniqueIdValidator,
	uniqueKey = uniqueKey
}
