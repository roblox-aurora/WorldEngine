local WorldEngine = game:GetService("ReplicatedStorage"):WaitForChild("WorldEngine")
local Object = require(WorldEngine:WaitForChild("Object"))
local t = require(WorldEngine:WaitForChild("t"))

local REGION_CONSTRUCTOR_ARGS = t.tuple(t.Vector3, t.Vector3, t.optional(t.CFrame), t.optional(t.string))

local Region = Object:Extend("Region")
function Region:constructor(vec0, vec1, cf, name)
	assert(REGION_CONSTRUCTOR_ARGS(vec0, vec1, cf, name))
	self._vec0 = vec0
	self._vec1 = vec1
	self._cframe = cf or (CFrame and CFrame.new(0, 0, 0))
	self._name = name or ""
end

function Region:GetName()
	return self._name
end

function Region:GetPoint0()
	return self._vec0
end

function Region:GetPoint1()
	return self._vec1
end

-- luacov: disable
-- this cannot be tested by Lemur... :(
function Region:ContainsPoint(point)
	assert(t.Vector3(point))

	local cframe, name = self._cframe, self._name
	local vec0 = cframe:PointToObjectSpace(self._vec0)
	local vec1 = cframe:PointToObjectSpace(self._vec1)

	local pPos = cframe:PointToObjectSpace(point)

	local px, py, pz = pPos.X, pPos.Y, pPos.Z -- point pos
	local v0x, v0y, v0z = vec0.X, vec0.Y, vec0.Z -- point0
	local v1x, v1y, v1z = vec1.X, vec1.Y, vec1.Z -- point1

	local boundsX = px > (v0x < v1x and v0x or v1x) --min(v0x, v1x);
	local boundsZ = pz > (v0z < v1z and v0z or v1z) --min(v0z, v1z);
	local boundsY = py > (v0y < v1y and v0y or v1y) --min(v0y, v1y);

	local boundsX1 = px < (v0x > v1x and v0x or v1x) --max(v0x, v1x);
	local boundsZ1 = pz < (v0z > v1z and v0z or v1z) --max(v0z, v1z);
	local boundsY1 = py < (v0y > v1y and v0y or v1y) --max(v0y, v1y);

	-- inRegion, regionName
	return (boundsX and boundsZ and boundsX1 and boundsZ1 and boundsY and boundsY1), name
end
-- luacov: enable

return Region
