local Maid = require(script.Parent.Maid)

return function()
	it(
		"should support basic maid",
		function()
			local maid = Maid.new()
			maid:Add(
				function()
				end
			)

			expect(#maid._tasks).to.equal(1)
		end
	)
	it(
		"should not support setting non-task values",
		function()
			local maid = Maid.new()

			expect(
				function()
					maid:Add(10)
				end
			).to.throw()
			expect(
				function()
					maid.Test = 10
				end
			).to.throw()
		end
	)
	it(
		"should get/set in maid",
		function()
			local maid = Maid.new()
			local newJob = function()
			end

			maid.Job = newJob

			local renderStepped =
				game:GetService("RunService").RenderStepped:Connect(
				function()
				end
			)
			maid.RenderStepped = renderStepped

			expect(maid.Job).to.be.ok()
			expect(maid.Job).to.equal(newJob)

			expect(maid.RenderStepped).to.be.ok()
			expect(maid.RenderStepped).to.equal(renderStepped)

			maid:Clean()

			expect(maid.Job).never.to.be.ok()
			expect(maid.RenderStepped).never.to.be.ok()
		end
	)
end
