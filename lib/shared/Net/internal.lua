local eventFolder
local functionsFolder

local function isValidRemoteType(value)
	return type(value) == "string" and (value == "RemoteEvent" or value == "RemoteEvent"), "Invalid type: " ..
		tostring(value) .. ", expected 'RemoteEvent' | 'RemoteFunction'"
end

local function findOrCreateFolder(folderName, parent)
	local existing = (parent or script):FindFirstChild(folderName)
	if existing then
		return existing
	else
		local newFolder = Instance.new("Folder")
		newFolder.Name = folderName
		newFolder.Parent = script or parent
	end
end

local function findOrCreateRemote(remoteType, name, throwIfNotExist)
	assert(isValidRemoteType(remoteType))
	assert(type(name) == "string", "Expected string")
	assert(type(throwIfNotExist) == "boolean" or throwIfNotExist == nil, "Expected boolean")

	local folder
	if remoteType == "RemoteEvent" then
		folder = eventFolder
	elseif remoteType == "RemoteFunction" then
		folder = functionsFolder
	end

	local existing = folder:FindFirstChild(name)
	if existing then
		return existing
	else
		if throwIfNotExist then
			error("Cannot find " .. tostring(remoteType) .. " '" .. tostring(name) .. "'")
		end

		local inst = Instance.new(remoteType)
		inst.Name = name
		inst.Parent = folder
		return inst
	end
end

eventFolder = findOrCreateFolder("Events")
functionsFolder = findOrCreateFolder("Functions")

return {
	findOrCreateRemote = findOrCreateRemote
}
