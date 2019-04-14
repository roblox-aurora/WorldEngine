local t = require(script.Parent.Parent:WaitForChild("t"))
local findRemoteOrThrow = require(script.Parent.internal).findRemoteOrThrow

local ClientEvent = {}
ClientEvent.__index = ClientEvent

function ClientEvent.new(name)
	local instance = findRemoteOrThrow("RemoteEvent", name)

	local self = {
		_name = name,
		_instance = instance
	}
	return setmetatable(self, ClientEvent)
end

function ClientEvent.is(value)
	return type(value) == "table" and getmetatable(value) == ClientEvent, "Expected ClientEvent"
end

function ClientEvent:Connect(fn)
	assert(t.callback(fn))

	return self._instance.OnClientEvent:Connect(fn)
end

function ClientEvent:SendToServer(...)
	self._instance:FireServer(...)
end

return ClientEvent