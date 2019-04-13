local WorldEngine = game:GetService("ReplicatedStorage"):WaitForChild("WorldEngine")
local Object = require(WorldEngine:WaitForChild("Object"))
local Region = require(script.Parent.Region)
local t = require(WorldEngine:WaitForChild("t"))

local IS_REGION_GROUP = t.tuple(t.string, t.optional(t.array(Region.instance)))

local RegionGroup = Object:Extend("RegionGroup")
function RegionGroup:constructor(name, regions)
	assert(IS_REGION_GROUP(name, regions))
	regions = regions or {}
	self._name = name
	self._regions = regions
end

function RegionGroup:AddRegion(region)
	assert(Region:Is(region), "Expected region")
	table.insert(self._regions, region)
end

function RegionGroup:GetRegionPointsAt(index)
	assert(t.number(index))
	local region = self._regions[index]
	if region then
		return region:GetPoint0(), region:GetPoint1(), region:GetName()
	end
end

-- luacov: disable
function RegionGroup:ContainsPoint(point)
	for _, region in next, self._regions do
		local inPoint, name = region:ContainsPoint(point)
		if inPoint then
			return true, name
		end
	end

	return false
end
-- luacov: enable

return RegionGroup
