--[[
	Creates Async methods
]]
local Promise = require(script.Parent.Promise)

local Promisify = {}
Promisify.__index = Promisify

--[[
	Used to await RBXScriptSignals, for single use events
	e.g.

	Players.PlayerAdded:Connect(function(player)
		Promisify:await(player.CharacterAdded):andThen(function(character)
			-- do stuff with character...
		end)
	end)
]]
-- function Promisify.from(signal)
-- 	assert(typeof(signal) == "RBXScriptSignal" or (typeof(signal) == "table" and typeof(signal.Wait) == "function"))
-- 	return Promise.new(
-- 		function(resolve, reject)
-- 			local results = {signal:Wait()}
-- 			resolve(unpack(results))
-- 		end
-- 	)
-- end

-- luacov: disable
local wrappable = {
	HttpService = {"GetAsync", "PostAsync", "RequestAsync"},
	DataStoreService = {"GetDataStore"},
	GlobalDataStore = {"SetAsync", "GetAsync", "RemoveAsync", "UpdateAsync", "IncrementAsync"},
	MarketplaceService = {"UserOwnsGamePassAsync", "PlayerOwnsAsset", "GetDeveloperProductsAsync", "GetProductInfo"},
	BadgeService = {"AwardBadge", "GetBadgeInfoAsync", "UserHasBadgeAsync"}
}
local function createAsyncWrapperFor(object)
	local wrapperList = wrappable[object.ClassName]
	if wrapperList then
		local asyncWrappers = {}
		for _, method in next, wrapperList do
			asyncWrappers[method] = function(_, ...)
				local argList = {...}
				return Promise.new(
					function(resolve, reject)
						-- Spawn to prevent yielding, since GetAsync yields.
						spawn(
							function()
								local ok, result = pcall(object[method], object, unpack(argList))

								if ok then
									if typeof(result) == "Instance" then
										resolve(createAsyncWrapperFor(result))
									else
										resolve(result)
									end
								else
									reject(result)
								end
							end
						)
					end
				)
			end
		end

		return setmetatable(
			asyncWrappers,
			{
				__index = object,
				__tostring = function()
					return "AsyncWrapper(" .. tostring(object) .. ")"
				end
			}
		)
	else
		return object
	end
end

-- Will wrap yielding methods as async methods
function Promisify.wrap(object)
	return createAsyncWrapperFor(object)
end

-- Gets a promise wrapped version of a service
function Promisify:GetService(serviceName)
	local service = game:GetService(serviceName)
	return createAsyncWrapperFor(service)
end
-- luacov: enable

function Promisify.default(_, value)
	assert(typeof(value) == "function")

	return function(...)
		local argList = {...}
		return Promise.new(
			function(resolve, reject)
				local ok, result = pcall(value, unpack(argList))
				if ok then
					resolve(result)
				else
					reject(result)
				end
			end
		)
	end
end
Promisify.__call = Promisify.default

return setmetatable({}, Promisify)
