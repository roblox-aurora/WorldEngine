local t = require(script.Parent.Parent:WaitForChild("t"))
local findOrCreateRemote = require(script.internal).findOrCreateRemote

local ClientEvent = {}
ClientEvent.__index = ClientEvent

function ClientEvent.new(name)
	local instance = findOrCreateRemote(name)

	local self = {
		_name = name,
		_instance = instance
	}
	return setmetatable(self, ClientEvent)
end

function ClientEvent:Connect(fn)
	assert(t.callback(fn))

	return self._instance.OnClientEvent:Connect(fn)
end

function ClientEvent:SendToServer(...)
	self._instance:FireServer(...)
end

return ClientEvent