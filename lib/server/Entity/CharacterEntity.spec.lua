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

	it(
		"should be able to heal and take damage",
		function()
			local test = TestPlayerEntity.new()
			test:TakeDamage(50)
			expect(test:GetHealth()).to.equal(150)

			test:Heal(20)
			expect(test:GetHealth()).to.equal(170)

			test:Heal(100)
			expect(test:GetHealth()).to.equal(200)

			test:TakeDamage(2 ^ 31 - 1)
			expect(test:GetHealth()).to.equal(0)
		end
	)
end
