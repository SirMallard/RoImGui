local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))

RoImGui:Start()

local childOpen: { boolean } = { true }

runService.RenderStepped:Connect(function(_: number)
	if RoImGui:Begin("First Window", { true }) then
		RoImGui:Text("1. Created inside one begin.")
	end
	RoImGui:End()

	RoImGui:Begin("Second Wider Window", { true })
	RoImGui:End()

	if RoImGui:Begin("A super-duper really long window name!", { true }) then
		RoImGui:Begin("Child window!", childOpen)
		RoImGui:End()
		RoImGui:Text("One line")
		RoImGui:Text("One line\nwith another line")
	end
	RoImGui:End()

	if RoImGui:Begin("First Window") then
		RoImGui:Text("2. Created inside another begin.")
	end
end)
