local Region = require(script.Parent.Region)
local RegionGroup = require(script.Parent.RegionGroup)

return function()
	it(
		"should be able to create RegionGroups",
		function()
			local group = RegionGroup.new("TestRegionGroup")
			group:AddRegion(Region.new(Vector3.new(0, 0, 0), Vector3.new(10, 10, 10)))
			group:AddRegion(Region.new(Vector3.new(10, 10, 10), Vector3.new(15, 15, 15)))

			local v0, v1 = group:GetRegionPointsAt(1)
			expect(v0).to.equal(Vector3.new(0, 0, 0))
			expect(v1).to.equal(Vector3.new(10, 10, 10))

			local v2, v3 = group:GetRegionPointsAt(2)
			expect(v2).to.equal(Vector3.new(10, 10, 10))
			expect(v3).to.equal(Vector3.new(15, 15, 15))
		end
	)
end
