local RunService = game:GetService("RunService")
local IS_CLIENT = RunService:IsClient()

-- local Dynamic = {}
-- Dynamic.__index = Dynamic

-- local function dynamic(modules)
-- 	return Promise.new(function(resolve, reject)

-- 	end)
-- end

if IS_CLIENT then
	return {
		ClientEvent = require(script.ClientEvent)
	}
else
	return {
		ServerEvent = require(script.ServerEvent)
	}
end