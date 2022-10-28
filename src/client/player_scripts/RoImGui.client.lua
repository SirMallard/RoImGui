local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))

RoImGui:Start()

runService.RenderStepped:Connect(function(deltaTime: number)
	RoImGui:Begin("First Window", { true })

	RoImGui:End()

	RoImGui:Begin("Second Wider Window", { true }, nil, {
		Position = Vector2.new(100, 60),
	})

	RoImGui:End()
end)
