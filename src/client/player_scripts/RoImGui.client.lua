local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))

RoImGui:ShowDemoWindow(true)
RoImGui:ShowDebugWindow(true)
RoImGui:Start()
