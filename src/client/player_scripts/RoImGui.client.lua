local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))
local Types = require(RoImGui.Types)

RoImGui:Start()

local childOpen: { boolean } = { true }
local booleanValue: { boolean } = { false }

local firstFlags: Types.WindowFlags = RoImGui.Flags.WindowFlags()
firstFlags.NoClose = true
firstFlags.NoCollapse = true

runService.RenderStepped:Connect(function(_: number)
	if RoImGui:Begin("One window", { true }, firstFlags) then
		RoImGui:Text("1. Created inside one begin.")
		RoImGui:Checkbox("Multi-window checkbox", booleanValue)
		RoImGui:End()
	end

	if RoImGui:Begin("A super-duper really long window name!", { true }) then
		RoImGui:Text("One line")
		RoImGui:Text("One line\nwith another line")
		RoImGui:Checkbox("A textbox", childOpen)
		RoImGui:Checkbox("Multi-window checkbox", booleanValue)
		RoImGui:End()
	end

	if RoImGui:Begin("Child window!", childOpen) then
		RoImGui:Text("This is a child window.")
		RoImGui:Checkbox("Multi-window checkbox", booleanValue)
		RoImGui:End()
	end
end)
