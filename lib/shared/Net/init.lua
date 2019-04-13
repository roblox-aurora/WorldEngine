local RunService = game:GetService("RunService")
local IS_CLIENT = RunService:IsClient()

--[[
	Very basic implementation of rbx-net
]]
if IS_CLIENT then
	return {
		ClientEvent = require(script.ClientEvent),
		ClientFunction = require(script.ClientFunction)
	}
else
	return {
		ServerEvent = require(script.ServerEvent),
		ServerFunction = require(script.ServerFunction)
	}
end
