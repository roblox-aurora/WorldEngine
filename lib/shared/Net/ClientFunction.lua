local t = require(script.Parent.Parent:WaitForChild("t"))
local Promise = require(script.Parent.Parent.Promise)
local findRemoteOrThrow = require(script.internal).findRemoteOrThrow

local ClientFunction = {}
ClientFunction.__index = ClientFunction

function ClientFunction.new(name)
	local instance = findRemoteOrThrow("RemoteFunction", name)

	local self = {
		_name = name,
		_instance = instance
	}

	return setmetatable(self, ClientFunction)
end

function ClientFunction:Callback(fn)
	assert(t.callback(fn))
	self._instance.OnServerInvoke = fn
end

function ClientFunction.is(value)
	return type(value) == "table" and getmetatable(value) == ClientFunction, "Expected ClientFunction"
end

function ClientFunction:CallServer(...)
	return self._instance:InvokeServer(...)
end

function ClientFunction:CallServerAsync(...)
	local args = {...}
	return Promise.new(
		function(resolve, reject)
			Promise.spawn(
				function()
					local ok, result = pcall(self._instance.InvokeServer, self._instance, unpack(args))
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

return ClientFunction