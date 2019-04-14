local t = require(script.Parent.Parent:WaitForChild("t"))
local Promise = require(script.Parent.Parent.Promise)
local findOrCreateRemote = require(script.Parent.internal).findOrCreateRemote

local ServerFunction = {}
ServerFunction.__index = ServerFunction

function ServerFunction.new(name)
	local instance = findOrCreateRemote("RemoteFunction", name)

	local self = {
		_name = name,
		_instance = instance
	}

	return setmetatable(self, ServerFunction)
end

function ServerFunction:Callback(fn)
	assert(t.callback(fn))
	self._instance.OnServerInvoke = fn
end

function ServerFunction.is(value)
	return type(value) == "table" and getmetatable(value) == ServerFunction, "Expected ServerFunction"
end

function ServerFunction:CallPlayerAsync(player, ...)
	local args = {...}
	return Promise.new(
		function(resolve, reject)
			Promise.spawn(
				function()
					local ok, result = pcall(self._instance.InvokeClient, self._instance, unpack(args))
					if ok then
						resolve(result)
					else
						reject(result)
					end
				end
			)
		end
	)
end


return ServerFunction