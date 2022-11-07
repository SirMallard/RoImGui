local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))
local Types = require(RoImGui.Types)

RoImGui:Start()

local childOpen: { boolean } = { true }

local firstFlags: Types.WindowFlags = RoImGui.Flags.WindowFlags()
firstFlags.NoClose = true
firstFlags.NoCollapse = true

runService.RenderStepped:Connect(function(_: number)
	if RoImGui:Begin("First Window", { true }, firstFlags) then
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
