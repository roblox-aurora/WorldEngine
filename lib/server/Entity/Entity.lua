local WorldEngine = game:GetService("ReplicatedStorage"):WaitForChild("WorldEngine")
local Object = require(WorldEngine:WaitForChild("Object"))

local Entity = Object:Extend("Entity")
function Entity:constructor()
	self._id = game:GetService("HttpService"):GenerateGUID(false):gsub("%-", "")
end

function Entity:GetId()
	return self._id
end

return Entity
