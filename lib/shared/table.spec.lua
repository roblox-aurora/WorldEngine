local table = require(script.Parent.table)

return function()
	it(
		"should handle mapping",
		function()
			local mapped =
				table.map(
				{"a", "b", "c", "d"},
				function(value)
					return value:upper()
				end
			)
			expect(mapped[1]).to.equal("A")
			expect(mapped[2]).to.equal("B")
			expect(mapped[3]).to.equal("C")
			expect(mapped[4]).to.equal("D")
		end
	)

	it(
		"should handle finding",
		function()
			local found =
				table.find(
				{"hello", "world"},
				function(value)
					return value == "hello"
				end
			)
			expect(found).to.equal("hello")
		end
	)

	it(
		"should handle filter",
		function()
			local filter =
				table.filter(
				{1, 2, 3, 4, 5, 6},
				function(value)
					return value % 2 == 0
				end
			)
			for i = 1, #filter do
				expect(filter[i] % 2).to.equal(0)
			end
		end
	)

	it(
		"should handle variations of table.remove",
		function()
			local testTable = {1, 2, 3, 4, "John Doe"}
			table.remove(testTable, "John Doe")

			expect(
				table.find(
					testTable,
					function(value)
						return value == "John Doe"
					end
				)
			).never.to.be.ok()

			table.remove(
				testTable,
				function(value)
					return value % 2 == 0
				end
			)

			expect(testTable[2]).to.equal(3)
		end
	)

	it(
		"should handle table.tostring",
		function()
			expect(table.tostring({1, 2, 3, 4})).to.equal("{[1] = 1, [2] = 2, [3] = 3, [4] = 4}")
			expect(table.tostring({a = 1, b = 2})).to.equal("{a = 1, b = 2}")
			expect(table.tostring({1, 2, {3, 4}})).to.equal("{[1] = 1, [2] = 2, [3] = {[1] = 3, [2] = 4}}")
			expect(table.tostring({a = 1, b = {c = 2}})).to.equal("{a = 1, b = {c = 2}}")
		end
	)

	it(
		"should handle table.join",
		function()
			local join = table.join({a = 1, b = 2, 10}, {c = 3}, {d = 4}, {5})
			expect(join.a).to.be.ok()
			expect(join.b).to.be.ok()
			expect(join.c).to.be.ok()
			expect(join.d).to.be.ok()
			expect(join[1]).to.equal(10)
			expect(join[2]).to.equal(5)
		end
	)
end
