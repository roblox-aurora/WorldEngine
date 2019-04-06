local Region = require(script.Parent.Region)

return function()
	it("should be able to create Regions", function()
		local region = Region.new(Vector3.new(0, 0, 0), Vector3.new(1, 1, 1), nil, "TestRegion")
		expect(region).to.be.ok()
		expect(region:GetPoint0()).to.equal(Vector3.new(0, 0, 0))
		expect(region:GetPoint1()).to.equal(Vector3.new(1, 1, 1))
		expect(region:GetName()).to.equal("TestRegion")
	end)
end