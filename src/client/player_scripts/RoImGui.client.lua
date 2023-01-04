local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))
local Types = require(RoImGui.Types)
local Colour4 = require(RoImGui.Colour4)
local Style = require(RoImGui.Style)

RoImGui:Start()

local childOpen: { boolean } = { true }
local booleanValue: { boolean } = { false }

local firstFlags: Types.WindowFlags = RoImGui.Flags.WindowFlags()
firstFlags.NoClose = true
firstFlags.NoCollapse = true

local colour: Types.Colour4 = Colour4.fromColour3(BrickColor.random().Color)

local counter: number = 0

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
		if RoImGui:BeginMenuBar() then
			if RoImGui:BeginMenu("File") then
				RoImGui:EndMenu()
			end
			if RoImGui:BeginMenu("Edit") then
				RoImGui:EndMenu()
			end
			if RoImGui:BeginMenu("Options") then
				RoImGui:EndMenu()
			end
			RoImGui:EndMenuBar()
		end

		if RoImGui:CollapsingHeader("Widgets") then
			if RoImGui:TreeNode("Text") then
				RoImGui:Text("One line")
				RoImGui:Text("One line\nwith another line")
				RoImGui:TextDisabled("This text is disabled!")
				RoImGui:Indent()
				RoImGui:Text("Indented text!")
				RoImGui:Unindent()
				RoImGui:TextColoured(colour, "Rainbow Text!")
				RoImGui:BulletText("A line with a bullet point!")
				RoImGui:Text("Time: %s", tostring(time()))

				RoImGui:TreePop()
			end
			if RoImGui:TreeNode("Checkbox") then
				RoImGui:Checkbox("A textbox", childOpen)
				RoImGui:Checkbox("Multi-window checkbox", booleanValue)

				RoImGui:TreePop()
			end
			if RoImGui:TreeNode("Button") then
				RoImGui:Button("Clicky button!")

				RoImGui:AlignTextToFramePadding()
				RoImGui:Text("Counter:")
				RoImGui:SameLine()
				if RoImGui:Button("-") then
					counter -= 1
				end
				RoImGui:SameLine(Style.Sizes.ItemInnerSpacing.X)
				if RoImGui:Button("+") then
					counter += 1
				end
				RoImGui:SameLine()
				RoImGui:Text(tostring(counter))

				if RoImGui:Button("Log") then
					print("Counter:", counter, "| This was logged in RoImGui.")
				end
				RoImGui:SameLine()
				RoImGui:Text("Simply writing to the output log.")

				RoImGui:TreePop()
			end
			if RoImGui:TreeNode("Tree Nodes") then
				for i = 1, 5 do
					local s: string = tostring(i)
					if RoImGui:TreeNode("Node " .. s) then
						RoImGui:Text("A child of tree node " .. s)
						RoImGui:TreePop()
					end
				end

				RoImGui:TreePop()
			end
		end

		if RoImGui:CollapsingHeader("Collapsing Header") then
			RoImGui:BulletText("Collapsing headers don't require an end statement.")
			RoImGui:BulletText("This is because any elements nested under it are drawn in\nthe if statement.")
			RoImGui:BulletText("Which makes it ideal for top level folders and organising\nelements.")
			RoImGui:BulletText("Unfourtunately, though, you can't write to it again once\nit has been closed.")
		end

		RoImGui:End()
	end
end)
