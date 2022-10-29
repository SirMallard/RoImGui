local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))

RoImGui:Start()

local childOpen: { boolean } = { true }

runService.RenderStepped:Connect(function(_: number)
	RoImGui:Begin("First Window", { true })
	RoImGui:End()

	RoImGui:Begin("Second Wider Window", { true })
	RoImGui:End()

	RoImGui:Begin("Third window!", { true })
	RoImGui:End()

	if RoImGui:Begin("A super-duper really long window name!", { true }) then
		RoImGui:Begin("Child window!", childOpen)
		RoImGui:End()
	end
	RoImGui:End()
end)
