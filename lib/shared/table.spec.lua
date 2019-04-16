local table = require(script.Parent.table)

local function symbol(name)
	local self = newproxy(true)
	local wrappedName = ("Symbol(%s)"):format(name)
	getmetatable(self).__tostring = function()
		return wrappedName
	end

	return self
end

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

			table.remove(testTable, 1)

			expect(testTable[1]).to.equal(3)
		end
	)

	it(
		"should handle table.tostring",
		function()
			expect(table.tostring({1, 2, 3, 4})).to.equal("{[1] = 1, [2] = 2, [3] = 3, [4] = 4}")
			expect(table.tostring({a = 1, b = 2})).to.equal("{a = 1, b = 2}")
			expect(table.tostring({1, 2, {3, 4}})).to.equal("{[1] = 1, [2] = 2, [3] = {[1] = 3, [2] = 4}}")
			expect(table.tostring({a = 1, b = {c = 2}}, {})).to.equal("{a = 1, b = {c = 2}}")

			expect(table.tostring({symbol("Test")})).to.equal("{[1] = <Symbol(Test)>}")
			expect(
				table.tostring(
					{
						function()
						end
					}
				)
			).to.equal("{[1] = <function>}")

			expect(table.tostring({Instance.new("Frame")})).to.equal("{[1] = <Frame>}")
			expect(table.tostring({"Test"})).to.equal('{[1] = "Test"}')
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

	it(
		"should handle table.copy",
		function()
			local oldTable = {1, 2, {3}}
			local newTable = table.copy(oldTable)

			expect(oldTable).never.to.equal(newTable)
			expect(oldTable[1]).to.equal(newTable[1])
			expect(oldTable[2]).to.equal(newTable[2])
			expect(oldTable[3]).never.to.equal(newTable[3])
			expect(oldTable[3][1]).to.equal(newTable[3][1])
		end
	)

	it(
		"should handle the advanced table.concat",
		function()
			expect(table.concat({1, 2, 3, {4, 5}}, ", ")).to.equal("1, 2, 3, [ 4, 5 ]")
		end
	)

	it(
		"should handle table.sub",
		function()
			local subTable = table.sub({1, 2, 3, 4}, 2)
			expect(table.tostring(subTable)).to.equal("{[1] = 2, [2] = 3, [3] = 4}")

			local subTable2 = table.sub({"a", "b", "c", "d", "e", "f"}, 2, 4)
			expect(table.tostring(subTable2)).to.equal("{[1] = \"b\", [2] = \"c\", [3] = \"d\"}")
		end
	)
end
