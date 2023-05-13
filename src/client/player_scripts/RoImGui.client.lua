local Players = game:GetService("Players")
local replicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService: RunService = game:GetService("RunService")
local RoImGui = require(replicatedStorage:WaitForChild("Modules"):WaitForChild("RoImGui"))
local TableInspector = require(replicatedStorage:WaitForChild("Libraries"):WaitForChild("TableInspector"))
local Types = require(RoImGui.Types)
local Colour4 = require(RoImGui.Colour4)
local Style = require(RoImGui.Style)

RoImGui:Start()

local inspector = TableInspector.new()
inspector:addTable("RoImGui", RoImGui.Internal)
inspector:addPath("Main Window", { RoImGui, "Internal", "Windows", "A super-duper really long window name!" })

local childOpen: { boolean } = { false }
local booleanValue: { boolean } = { false }

local firstFlags: Types.Flag = bit32.bor(RoImGui.Flags.WindowFlags.NoClose, RoImGui.Flags.WindowFlags.NoCollapse)

local colour: Types.Colour4 = Colour4.fromColour3(BrickColor.random().Color)
local red: Types.Colour4 = Colour4.fromColour3(BrickColor.Red().Color)
local green: Types.Colour4 = Colour4.fromColour3(BrickColor.Green().Color)
local blue: Types.Colour4 = Colour4.fromColour3(BrickColor.Blue().Color)

local counter: number = 0
local radioValue: { number } = { 0 }
local textString: { string } = { "random string	" }

runService.RenderStepped:Connect(function(_: number)
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
				RoImGui:PushId("Time: ###")
				RoImGui:Text("Time: %f", time())

				RoImGui:Separator()

				RoImGui:LabelText("A string text value", "Demonstration")
				RoImGui:LabelText("Large part of window", "Small part")

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

				RoImGui:Separator()

				RoImGui:RadioButton("Button 1", radioValue, 0)
				RoImGui:SameLine()
				RoImGui:RadioButton("Button 2", radioValue, 1)
				RoImGui:SameLine()
				RoImGui:RadioButton("Button 3", radioValue, 2)

				RoImGui:Separator()

				RoImGui:PushColour("CheckMark", red)
				RoImGui:RadioButton("Red", radioValue, 0)
				RoImGui:SameLine()
				RoImGui:PushColour("CheckMark", green)
				RoImGui:RadioButton("Green", radioValue, 1)
				RoImGui:SameLine()
				RoImGui:PushColour("CheckMark", blue)
				RoImGui:RadioButton("Blue", radioValue, 2)
				RoImGui:PopColour("CheckMark")

				RoImGui:TreePop()
			end
			if RoImGui:TreeNode("Tree Nodes") then
				for i = 1, 5 do
					if RoImGui:TreeNode("Node " .. tostring(i)) then
						RoImGui:Text("A child of tree node %d", i)
						RoImGui:TreePop()
					end
				end

				RoImGui:TreePop()
			end
			if RoImGui:TreeNode("Input") then
				RoImGui:InputText("Text", textString)

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
