local Demo = {}

local Types = require(script.Parent.Types)
local Flags = require(script.Parent.Flags)
local Style = require(script.Parent.Utility.Style)
local Colour4 = require(script.Parent.Utility.Colour4)
local ImGuiInternal = require(script.Parent.ImGuiInternal)

Demo.DemoWindow = false
Demo.DebugWindow = false

local colour: Types.Colour4 = Colour4.fromColour3(BrickColor.palette(90).Color)
local red: Types.Colour4 = Colour4.fromColour3(BrickColor.Red().Color)
local green: Types.Colour4 = Colour4.fromColour3(BrickColor.Green().Color)
local blue: Types.Colour4 = Colour4.fromColour3(BrickColor.Blue().Color)

local anotherCheckbox: { boolean } = { false }

local counter: number = 0
local radioValue: { number } = { 0 }

local textString: { string } = { "random string	" }
local integerValue: { number } = { 100 }
local floatValue: { number } = { 11.12 }

local nested_table = {
	checkbox_one = false,
	checkbox_two = false,
}

local checkbox_one = { nested_table, "checkbox_one" }
local checkbox_two = { nested_table, "checkbox_two" }

function Demo:ShowDebugWindow(ImGui: Types.ImGui)
	if Demo.DebugWindow == false then
		return
	end

	local flags: Types.Flag = Flags.WindowFlags.NoClose

	if ImGui:Begin("Debug", { true }, flags) then
		ImGui:Text("Debug Window.\nFor showing internal data. The data is accurate for this frame since the\n")
		if ImGui:TreeNode("ID") then
			ImGui:ChangingText(
				"ActiveId: ###",
				"ActiveId: %s",
				(#ImGuiInternal.ActiveId ~= 0) and ImGuiInternal.ActiveId or "-----"
			)
			ImGui:ChangingText(
				"HoverId: ###",
				"HoverId: %s",
				(#ImGuiInternal.HoverId ~= 0) and ImGuiInternal.HoverId or "-----"
			)

			ImGui:TreePop()
		end

		if ImGui:TreeNode("Windows") then
			ImGui:ChangingText(
				"Hovered Window: ###",
				"Hovered Window: %s",
				ImGuiInternal.HoveredWindow and ImGuiInternal.HoveredWindow.Id or "-----"
			)
			ImGui:ChangingText(
				"Moving Window: ###",
				"Moving Window: %s",
				ImGuiInternal.MovingWindow and ImGuiInternal.MovingWindow.Id or "-----"
			)
			ImGui:ChangingText(
				"Nav Window: ###",
				"Nav Window: %s",
				ImGuiInternal.NavWindow and ImGuiInternal.NavWindow.Id or "-----"
			)
			ImGui:ChangingText(
				"Resizing Window: ###",
				"Resizing Window: %s",
				ImGuiInternal.ResizingWindow and ImGuiInternal.ResizingWindow.Id or "-----"
			)

			ImGui:TreePop()
		end

		if ImGui:TreeNode("Mouse") then
			ImGui:ChangingText(
				"Mouse Position: (###)",
				"Mouse Position: (%s)",
				tostring(ImGuiInternal.MouseCursor.Position)
			)
			ImGui:ChangingText("Mouse Delta: (###)", "Mouse Delta: (%s)", tostring(ImGuiInternal.MouseCursor.Delta))
			ImGui:ChangingText("Hold Offset: (###)", "Hold Offset: (%s)", tostring(ImGuiInternal.HoldOffset))

			ImGui:TreePop()
		end
		ImGui:Checkbox("Show Item Picker", ImGuiInternal.Debug.HoverDebug)
		ImGui:End()
	end

	if ImGuiInternal.Debug.HoverDebug[1] == true and ImGuiInternal.HoverId ~= "" then
		ImGuiInternal.Debug.HoverElement.stroke.Enabled = true
	else
		ImGuiInternal.Debug.HoverElement.stroke.Enabled = false
	end
end

function Demo:ShowDemoWindow(ImGui: Types.ImGui)
	if Demo.DemoWindow == false then
		return
	end

	if ImGui:Begin("Demo Window", { true }) then
		if ImGui:BeginMenuBar() then
			if ImGui:BeginMenu("File") then
				ImGui:EndMenu()
			end
			if ImGui:BeginMenu("Edit") then
				ImGui:EndMenu()
			end
			if ImGui:BeginMenu("Options") then
				ImGui:EndMenu()
			end
			ImGui:EndMenuBar()
		end

		if ImGui:CollapsingHeader("Widgets") then
			if ImGui:TreeNode("Text") then
				ImGui:Text("One line")
				ImGui:Text("One line\nwith another line")
				ImGui:TextDisabled("This text is disabled!")
				ImGui:Indent()
				ImGui:Text("Indented text!")
				ImGui:Unindent()
				ImGui:TextColoured(colour, "Rainbow Text!")
				ImGui:BulletText("A line with a bullet point!")
				ImGui:PushId("Time: ###")
				ImGui:Text("Time: %f", time())

				ImGui:Separator()

				ImGui:LabelText("A string text value", "Demonstration")
				ImGui:LabelText("Large part of window", "Small part")

				ImGui:TreePop()
			end
			if ImGui:TreeNode("Checkbox") then
				ImGui:Checkbox("Show another checkbox", anotherCheckbox)
				if anotherCheckbox[1] == true then
					ImGui:Checkbox("Hide this checkbox", anotherCheckbox)
				end

				ImGui:Separator()

				ImGui:Checkbox("Checkbox one", checkbox_one)
				ImGui:Checkbox("Checkbox two", checkbox_two)

				ImGui:TreePop()
			end
			if ImGui:TreeNode("Button") then
				ImGui:Button("Clicky button!")

				ImGui:AlignTextToFramePadding()
				ImGui:Text("Counter:")
				ImGui:SameLine()
				if ImGui:Button("<", Style.Sizes.TextSize + 2 * Style.Sizes.FramePadding.Y) then
					counter -= 1
				end
				ImGui:SameLine(Style.Sizes.ItemInnerSpacing.X)
				if ImGui:Button(">", Style.Sizes.TextSize + 2 * Style.Sizes.FramePadding.Y) then
					counter += 1
				end
				ImGui:SameLine()
				ImGui:Text(tostring(counter))

				if ImGui:Button("Log") then
					print("Counter:", counter, "| This was logged in ImGui.")
				end
				ImGui:SameLine()
				ImGui:Text("Simply writing to the output log.")

				ImGui:Separator()

				ImGui:RadioButton("Button 1", radioValue, 0)
				ImGui:SameLine()
				ImGui:RadioButton("Button 2", radioValue, 1)
				ImGui:SameLine()
				ImGui:RadioButton("Button 3", radioValue, 2)

				ImGui:Separator()

				ImGui:PushColour("CheckMark", red)
				ImGui:RadioButton("Red", radioValue, 0)
				ImGui:SameLine()
				ImGui:PushColour("CheckMark", green)
				ImGui:RadioButton("Green", radioValue, 1)
				ImGui:SameLine()
				ImGui:PushColour("CheckMark", blue)
				ImGui:RadioButton("Blue", radioValue, 2)
				ImGui:PopColour("CheckMark")

				ImGui:TreePop()
			end
			if ImGui:TreeNode("Tree Nodes") then
				for i = 1, 5 do
					if ImGui:TreeNode("Node " .. tostring(i)) then
						ImGui:Text("A child of tree node %d", i)
						ImGui:TreePop()
					end
				end

				ImGui:TreePop()
			end
			if ImGui:TreeNode("Input") then
				ImGui:InputText("Text", textString)
				ImGui:InputTextWithHint("Placeholder Text", textString, "secret behind the line")
				ImGui:InputInteger("Integer Input", integerValue, -100, 100)
				ImGui:InputFloat("Float Input", floatValue, nil, nil, "%.4f")

				ImGui:TreePop()
			end
		end

		if ImGui:CollapsingHeader("Collapsing Header") then
			ImGui:BulletText("Collapsing headers don't require an end statement.")
			ImGui:BulletText("This is because any elements nested under it are drawn in\nthe if statement.")
			ImGui:BulletText("Which makes it ideal for top level folders and organising\nelements.")
			ImGui:BulletText("Unfourtunately, though, you can't write to it again once\nit has been closed.")
		end

		ImGui:End()
	end
end

return Demo
