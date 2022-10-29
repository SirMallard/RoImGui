local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))

RoImGui:Start()

runService.RenderStepped:Connect(function(_: number)
	RoImGui:Begin("First Window", { true })
	RoImGui:End()

	RoImGui:Begin("Second Wider Window", { true })
	RoImGui:End()

	RoImGui:Begin("Third window!", { true })
	RoImGui:End()

	RoImGui:Begin("A super-duper really long window name!")
	RoImGui:End()

	for i = 1, 10 do
		RoImGui:Begin("Window #" .. tostring(i))
		RoImGui:End()
	end
end)
