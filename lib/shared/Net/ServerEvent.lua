local t = require(script.Parent.Parent:WaitForChild("t"))
local findOrCreateRemote = require(script.Parent.internal).findOrCreateRemote

local ServerEvent = {}
ServerEvent.__index = ServerEvent
local tplayer = t.instanceIsA("Player");

function ServerEvent.new(name)
	local instance = findOrCreateRemote("RemoteEvent", name)

	local self = {
		_name = name,
		_instance = instance
	}
	return setmetatable(self, ServerEvent)
end

function ServerEvent:Connect(fn)
	assert(t.callback(fn))

	return self._instance.OnServerEvent:Connect(fn)
end

function ServerEvent.is(value)
	return type(value) == "table" and getmetatable(value) == ServerEvent, "Expected ServerEvent"
end

function ServerEvent:SendToPlayer(player, ...)
	assert(tplayer(player))

	self._instance:FireClient(player, ...)
end

function ServerEvent:SendToPlayers(players, ...)
	assert(t.array(tplayer(players)))

	for _, player in next, players do
		self._instance:FireClient(player, ...)
	end
end

function ServerEvent:SendToAllPlayers(...)
	self._instance:FireAllClients(...)
end

return ServerEvent