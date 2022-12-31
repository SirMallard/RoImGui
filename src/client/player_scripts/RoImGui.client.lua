local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))
local Types = require(RoImGui.Types)
local Colour4 = require(RoImGui.Colour4)

RoImGui:Start()

local childOpen: { boolean } = { true }
local booleanValue: { boolean } = { false }

local firstFlags: Types.WindowFlags = RoImGui.Flags.WindowFlags()
firstFlags.NoClose = true
firstFlags.NoCollapse = true

local colour: Types.Colour4 = Colour4.fromColour3(BrickColor.random().Color)

runService.RenderStepped:Connect(function(_: number)
	if RoImGui:Begin("Demo", { true }) then
		RoImGui:Text("Single line.")
	end

	if RoImGui:Begin("One window", { true }, firstFlags) then
		RoImGui:Text("1. Created inside one begin.")
		RoImGui:Checkbox("Multi-window checkbox", booleanValue)
		if RoImGui:Button("Change Text Colour") then
			colour = Colour4.fromColour3(BrickColor.random().Color)
		end
		RoImGui:End()
	end

	if RoImGui:Begin("Child window!", childOpen) then
		RoImGui:Text("This is a child window.")
		RoImGui:Checkbox("Multi-window checkbox", booleanValue)
		RoImGui:End()
	end

	if RoImGui:Begin("A super-duper really long window name!", { true }) then
		RoImGui:Text("One line")
		RoImGui:Text("One line\nwith another line")
		RoImGui:Checkbox("A textbox", childOpen)
		RoImGui:Checkbox("Multi-window checkbox", booleanValue)

		RoImGui:TextDisabled("This text is disabled!")
		RoImGui:Text("Inbetween text!")
		RoImGui:TextColoured(colour, "Rainbow Text!")
		RoImGui:BulletText("A line with a bullet point!")
		RoImGui:Text("Time: %s", tostring(time()))
		RoImGui:End()
	end
end)
