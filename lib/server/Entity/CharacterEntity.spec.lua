local CharacterEntity = require(script.Parent.CharacterEntity)
local TestPlayerEntity = CharacterEntity:Extend("TestPlayerEntity")
function TestPlayerEntity:constructor()
	CharacterEntity:super(self, 200)
end

return function()
	it(
		"should have an id",
		function()
			local test = TestPlayerEntity.new()
			expect(test:GetId()).to.be.ok()
		end
	)
	it(
		"should handle health",
		function()
			local test = TestPlayerEntity.new()
			expect(test:GetHealth()).to.equal(200)
			expect(test:IsAlive()).to.equal(true)
		end
	)

	it(
		"should be able to modify health",
		function()
			local test = TestPlayerEntity.new()
			test:SetHealth(1000)

			expect(test:GetHealth()).to.equal(1000)
		end
	)
end
