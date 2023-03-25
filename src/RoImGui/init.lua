local runService: RunService = game:GetService("RunService")

local components = script.Components
local Types = require(script.Types)
local ImGuiInternal: Types.ImGuiInternal = require(script.ImGuiInternal)
local Style = require(script.Utility.Style)
local Utility = require(script.Utility.Utility)
local Flags = require(script.Flags)

--[[
	Requiring all of the elements	
]]
--
local Window = require(components.Window)

local Menu = require(components.Menu)

local Text = require(components.Text)
local Checkbox = require(components.Checkbox)
local Button = require(components.Button)
local RadioButton = require(components.RadioButton)

local LabelText = require(components.LabelText)
local InputText = require(components.InputText)

local TreeNode = require(components.TreeNode)
local Header = require(components.Header)

local startFrameId: number = -1
local endFrameId: number = -1
-- local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

local DefaultWindowFlags: Types.Flag = 0
local DefaultTextFlags: Types.Flag = 0

local BulletTextFlags: Types.Flag = Flags.TextFlags.BulletText

local ImGui: Types.ImGui = {} :: Types.ImGui

ImGui.FrameId = startFrameId
ImGui.Flags = Flags
ImGui.Types = script.Types
ImGui.Colour4 = script.Utility.Colour4
ImGui.Style = script.Utility.Style

function ImGui:DebugWindow()
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

	-- local window: Types.ImGuiWindow = ImGui:GetWindowById("Debug")
	-- window.Active = true
end

--[[
	Initialisation API
	
	:Start()
	:Stop()
	:Pause()
]]
function ImGui:Start()
	assert((ImGuiInternal.Status ~= "Started"), "Cannot call :Start() without stopping or pausing first.")

	ImGuiInternal:Initialise()

	-- These will be called at the very start and very end of each render stepped, as long as they are connected
	-- first.

	-- These are not unbound because they are rendered first and last because they connected first to the events.
	-- A later call to :BindToRenderStep() with the same priority will be placed at the end of the call stack.
	-- Therefore to ensure this callback happens first and before any other bindings, it must be connected first
	-- and stay bound.
	runService:BindToRenderStep("ImGuiRender", Enum.RenderPriority.First.Value, function(deltaTime: number)
		if ImGuiInternal.Status ~= "Started" then
			return
		end

		startFrameId += 1
		ImGui.FrameId = startFrameId
		ImGuiInternal:UpdateTime(deltaTime)

		ImGui:SetHover("", "")

		ImGuiInternal:UpdateMouseInputs()
		ImGui:UpdateWindowResize()
		ImGui:UpdateWindowMove()
		ImGui:FindHoveredWindow()
	end)

	-- Calling :RenderStepped() will schedule the function to the front of the call stack. Therefore to ensure this callback happens last and
	-- after any other bindings, it must be connected first and stay bound.
	runService.RenderStepped:Connect(function()
		if ImGuiInternal.Status ~= "Started" then
			return
		end

		endFrameId += 1
		if endFrameId ~= startFrameId then
			print("⏰ Out of sync? 😤")
		end
		ImGui:DebugWindow()

		ImGui:EndFrameMouseUpdate()
		ImGui:CleanWindowElements()
	end)
end

function ImGui:Stop()
	assert((ImGuiInternal.Status ~= "Stopped"), "Cannot call :Stop() without starting or pausing first.")

	ImGuiInternal.Status = "Stopped"
end

function ImGui:Pause()
	assert((ImGuiInternal.Status ~= "Started"), "Cannot call :Pause() without starting first.")

	ImGuiInternal.Status = "Paused"
end

--[[
	Functions to be called before or after code.
	
	Generally for cleaning and updating last frame data.
]]
function ImGui:CleanWindowElements()
	for windowIndex: string, window: Types.ImGuiWindow in ImGuiInternal.Windows do
		window.WasActive = window.Active
		window.Active = false

		if (window.WasActive == false) or (window.Open[1] == false) then
			table.remove(ImGuiInternal.WindowFocusOrder, window.FocusOrder)
			ImGuiInternal.Windows[windowIndex] = nil

			if ImGuiInternal.ActiveWindow == window then
				ImGui:SetActive("", "", nil)
			end
			if ImGuiInternal.NavWindow == window then
				ImGui:SetNavWindow(nil)
			end
			if ImGuiInternal.HoveredWindow == window then
				ImGuiInternal.HoveredWindow = nil
			end
			if ImGuiInternal.MovingWindow == window then
				ImGuiInternal.MovingWindow = nil
			end
			if ImGuiInternal.CurrentWindow == window then
				ImGuiInternal.CurrentWindow = nil
			end
			if ImGuiInternal.ResizingWindow == window then
				ImGuiInternal.ResizingWindow = nil
			end

			window:Destroy()
		end

		-- loop through all menubars
		local menubar: Types.WindowMenubar = window.Window.Menubar
		for name: string, menu: Types.ImGuiMenu in menubar.Menus do
			menu.Active = false

			if menu.LastFrameActive < endFrameId then
				menu:Destroy()
				window.Window.Menubar.Menus[name] = nil
			end
		end

		menubar.DrawCursor.Position = menubar.DrawCursor.StartPosition
		menubar.DrawCursor.PreviousPosition = menubar.DrawCursor.PreviousPosition

		-- loop through all window elements
		local frame: Types.ElementFrame = window.Window.Frame

		for elementIndex: number, element: Types.Element in frame.Elements do
			if element.LastFrameActive < endFrameId then
				if element["Destroy"] == nil then
					element.Instance:Destroy()
				else
					element:Destroy()
				end
				table.remove(frame.Elements, elementIndex)
			else
				element.Active = false
			end
		end

		frame.DrawCursor.Position = frame.DrawCursor.StartPosition
		frame.DrawCursor.PreviousPosition = frame.DrawCursor.StartPosition

		frame.DrawCursor.LineHeight = 0
		frame.DrawCursor.PreviousLineHeight = 0

		frame.DrawCursor.TextLineOffset = 0
		frame.DrawCursor.PreviousTextLineOffset = 0

		frame.DrawCursor.Indent = 0
		frame.DrawCursor.SameLine = false

		window.RedrawThisFrame = window.RedrawNextFrame
		window.RedrawNextFrame = false
	end
end

function ImGui:UpdateWindowFocusOrder(window: Types.ImGuiWindow?)
	if window.FocusOrder == #ImGuiInternal.WindowFocusOrder then
		return
	end

	if window ~= nil then
		local index: number = table.find(ImGuiInternal.WindowFocusOrder, window)
		table.remove(ImGuiInternal.WindowFocusOrder, index)
		table.insert(ImGuiInternal.WindowFocusOrder, window)
	end

	for order: number, focusWindow: Types.ImGuiWindow in ImGuiInternal.WindowFocusOrder do
		focusWindow.FocusOrder = order
		if focusWindow.Window.Instance ~= nil then
			focusWindow.Window.Instance.ZIndex = order
		end
	end
end

function ImGui:FindHoveredWindow()
	ImGuiInternal.HoveredWindow = nil

	-- local topWindow: Types.ImGuiWindow? = ImGuiInternal.WindowFocusOrder[#ImGuiInternal.WindowFocusOrder]
	-- print(topWindow ~= nil and topWindow.Id or "nil")

	for index = #ImGuiInternal.WindowFocusOrder, 1, -1 do
		local window = ImGuiInternal.WindowFocusOrder[index]
		local instance: Frame? = window.Window.Instance
		if (window.WasActive == false) or (instance == nil) then
			continue
		end

		if Flags.Enabled(window.Flags, Flags.WindowFlags.NoResize) == true then
			if Utility.IsCursorInBox(instance.AbsolutePosition, instance.AbsoluteSize) == false then
				continue
			end
		else
			local position: Vector2 = instance.AbsolutePosition
			local size: Vector2 = instance.AbsoluteSize
			local outer: number = Style.Sizes.ResizeOuterPadding
			local inner: number = Style.Sizes.ResizeInnerPadding

			if
				(
					Utility.IsCursorInBox(
						position + Vector2.new(-outer, inner),
						size + Vector2.new(2 * outer, outer - inner)
					) == false
				)
				and (Utility.IsCursorInBox(position, Vector2.new(size.X, inner)) == false)
				and (
					Utility.IsCursorInBox(position + Vector2.new(inner, -outer), Vector2.new(size.X - 2 * inner, outer))
					== false
				)
			then
				continue
			end
		end

		ImGuiInternal.HoveredWindow = window
		break
	end
end

-- Updates RootWindow properties of the current window based upon flags
function ImGui:UpdateWindowLinks(window: Types.ImGuiWindow, flags: Types.Flag, parentWindow: Types.ImGuiWindow?)
	window.ParentWindow = parentWindow
	window.RootWindow, window.PopupRootWindow, window.PopupParentRootWindow = window, window, window
	if
		(parentWindow ~= nil)
		and (Flags.Enabled(flags, Flags.WindowFlags.ChildWindow) == true)
		and (Flags.Enabled(flags, Flags.WindowFlags.Tooltip) == false)
	then
		window.RootWindow = parentWindow.RootWindow
	end
	if (parentWindow ~= nil) and (Flags.Enabled(flags, Flags.WindowFlags.Popup) == true) then
		window.PopupRootWindow = parentWindow.PopupRootWindow
	end
	if
		(parentWindow ~= nil)
		and not (Flags.Enabled(flags, Flags.WindowFlags.Modal) == true)
		and (
			Flags.Enabled(flags, Flags.WindowFlags.ChildWindow) == true
			or Flags.Enabled(flags, Flags.WindowFlags.Popup) == true
		)
	then
		window.PopupParentRootWindow = parentWindow.PopupParentRootWindow
	end
end

function ImGui:EndFrameMouseUpdate()
	if (ImGuiInternal.ActiveId ~= "") or (ImGuiInternal.HoverId ~= "") then
		return
	end

	if ImGuiInternal.MouseButton1.DownOnThisFrame == true then
		local hoveredWindow: Types.ImGuiWindow? = ImGuiInternal.HoveredWindow

		if hoveredWindow ~= nil then
			if hoveredWindow.Window.Instance == nil then
				return
			end

			ImGui:SetNavWindow(hoveredWindow)
			ImGui:UpdateWindowFocusOrder(hoveredWindow)
			ImGuiInternal.MovingWindow = hoveredWindow
			ImGuiInternal.HoldOffset = ImGuiInternal.MouseCursor.Position - hoveredWindow.Position
		elseif ImGuiInternal.NavWindow ~= nil then
			ImGui:SetNavWindow(nil)
		end
	end
end

--[[
	BUTTON FUNCTIONS
]]

--[[
	Button Behaviour functions

	ItemHoverable()
	ButtonBehaviour()
]]
function ItemHoverable(
	position: Vector2,
	size: Vector2,
	id: Types.ImGuiId,
	class: Types.ImGuiClass,
	window: Types.ImGuiWindow
)
	if (ImGuiInternal.HoverId ~= "") and ((ImGuiInternal.HoverId ~= id) and (ImGuiInternal.HoverClass ~= class)) then
		return false
	end

	if ImGuiInternal.HoveredWindow and ImGuiInternal.HoveredWindow.Id ~= window.Id then
		return false
	end

	if (ImGuiInternal.ActiveId ~= "") and ((ImGuiInternal.ActiveId ~= id) and (ImGuiInternal.ActiveClass ~= class)) then
		return false
	end

	if Utility.IsCursorInBox(position, size) == false then
		return false
	end

	if ImGuiInternal.Debug.HoverDebug[1] == true then
		ImGuiInternal.Debug.HoverElement.Position = UDim2.fromOffset(position.X, position.Y)
		ImGuiInternal.Debug.HoverElement.Size = UDim2.fromOffset(size.X, size.Y)
	end

	return true
end

--[[
	Notes on button drawing:
		- the buttons are drawn once and will not be redrawn because of a hover/hold/normal state.
			- only excepetional changes call for a redraw
		- the buttons *STORE THEIR STATE*
]]
function ButtonBehaviour(
	position: Vector2,
	size: Vector2,
	id: Types.ImGuiId,
	class: Types.ImGuiClass,
	window: Types.ImGuiWindow
): (boolean, boolean, boolean)
	-- Todo: create the UI ids so I can reference the current id.
	-- Todo: check whether the active and hovered are currently this button.
	-- Todo: all button checking behaviour.

	local hovered: boolean = ItemHoverable(position, size, id, class, window)
	local held: boolean, pressed: boolean = false, false

	if hovered == true then
		ImGui:SetHover(id, class)
		if (ImGuiInternal.MouseButton1.DownOnThisFrame == true) and (ImGuiInternal.ActiveId ~= id) then
			ImGui:SetActive(id, class, window)

			ImGui:SetNavWindow(window)
			ImGui:UpdateWindowFocusOrder(window)
		end
	end

	if (ImGuiInternal.ActiveId == id) and (ImGuiInternal.ActiveClass == class) then
		if ImGuiInternal.MouseButton1.Down == true then
			held = true
		else
			if hovered == true then
				pressed = true
			end
			ImGui:SetActive("", "", nil)
		end
	end

	return pressed, hovered, held
end

--[[
	Used for updating the colour and state of a button by most button objects.
	The logic is in order of precedence for the colours.
]]
function ButtonLogic(
	instance: Frame | ImageLabel | TextLabel,
	hovered: boolean,
	held: boolean,
	button: Types.Button,
	styleType: number,
	styles: Types.ButtonStyle
)
	local colour: string = if styleType == 0 then "BackgroundColor3" else "ImageColor3"
	local transparency: string = if styleType == 0 then "BackgroundTransparency" else "ImageTransparency"

	local state: number = button.State
	local newState: number = -1

	if hovered == true then
		if (held == true) and (state ~= 2) then
			instance[colour] = styles[2].Colour
			instance[transparency] = styles[2].Transparency
			newState = 2
		elseif (held == false) and (state ~= 1) then
			instance[colour] = styles[1].Colour
			instance[transparency] = styles[1].Transparency
			newState = 1
		end
	elseif state ~= 0 then
		instance[colour] = styles[0].Colour
		instance[transparency] = styles[0].Transparency
		newState = 0
	end

	if newState ~= -1 then
		button.State = newState
	end

	return newState
end

--[[
	Used to increment the draw cursor for the next item. Called after the item has been placed to setup
	the position for the next one.
]]
function ItemSize(drawCursor: Types.DrawCursor, size: Vector2, textPadding: number?)
	local lineOffset: number = (textPadding ~= nil)
			and (textPadding > 0)
			and math.max(0, drawCursor.TextLineOffset - textPadding)
		or 0
	local linePosition: number = (drawCursor.SameLine == true) and drawCursor.PreviousPosition.Y
		or drawCursor.Position.Y
	local lineHeight: number =
		math.max(drawCursor.LineHeight, drawCursor.Position.Y - linePosition + size.Y + lineOffset)

	drawCursor.PreviousPosition = Vector2.new(drawCursor.Position.X + size.X, linePosition)
	drawCursor.Position = Vector2.new(drawCursor.Indent, linePosition + lineHeight + Style.Sizes.ItemSpacing.Y)
	drawCursor.PreviousLineHeight = lineHeight
	drawCursor.LineHeight = 0
	drawCursor.PreviousTextLineOffset = math.max(drawCursor.TextLineOffset, textPadding or 0)

	drawCursor.SameLine = false
end

--[[
	Additional functions

]]

function ImGui:GetWindowById(windowName: string): Types.ImGuiWindow?
	return ImGuiInternal.Windows[windowName] or nil
end

function ImGui:CreateWindow(windowName: string, flags: Types.Flag): Types.ImGuiWindow
	local parentWindow: Types.ImGuiWindow? = nil

	local window: Types.ImGuiWindow = Window.new(windowName, parentWindow, flags)

	ImGuiInternal.Windows[windowName] = window
	table.insert(ImGuiInternal.WindowFocusOrder, window)
	window.FocusOrder = #ImGuiInternal.WindowFocusOrder - 1

	return window
end

function ImGui:SetNavWindow(window: Types.ImGuiWindow | nil)
	local previousWindow: Types.ImGuiWindow? = ImGuiInternal.NavWindow

	if previousWindow == window then
		return
	end
	ImGuiInternal.NavWindow = window

	if previousWindow ~= nil then
		previousWindow:UpdateTitleColour()
	end

	if window ~= nil then
		window:UpdateTitleColour()
	end
end

function ImGui:SetActive(id: Types.ImGuiId, class: Types.ImGuiClass, window: Types.ImGuiWindow | nil)
	ImGuiInternal.ActiveId = id
	ImGuiInternal.ActiveClass = class
	ImGuiInternal.ActiveWindow = window
end

function ImGui:SetHover(id: Types.ImGuiId, class: Types.ImGuiClass)
	ImGuiInternal.HoverId = id
	ImGuiInternal.HoverClass = class
end

-- Gets the top element frame from the element frame stack.
-- Returns the most recent frame for placing all the elements into.
function ImGui:GetActiveElementFrame(): ()
	local elementFrameStackLength: number = #ImGuiInternal.ElementFrameStack
	if (ImGuiInternal.CurrentWindow == nil) or (elementFrameStackLength == 0) then
		return
	end

	return ImGuiInternal.ElementFrameStack[elementFrameStackLength]
end

-- Loops through all children in the element frame and checks the id and class for the desired element.
function ImGui:GetElementById(
	id: Types.ImGuiId,
	class: string,
	elementFrame: Types.ElementFrame,
	active: boolean?
): Types.Element?
	-- local element: Types.Element

	for _, childElement: Types.ImGuiText in elementFrame.Elements do
		if
			(childElement.Id == id)
			and (childElement.Class == class)
			and ((active == nil) or (childElement.Active == false))
		then
			return childElement
			-- element = childElement
			-- break
		end
	end

	-- return element
end

function ImGui:PushId(id: Types.ImGuiId)
	ImGuiInternal.NextItemData.Id = id
	ImGuiInternal.NextItemData.Reset = true
end

function ImGui:PushColour(index: string, colour: Types.Colour4)
	Style.Colours[index] = colour
end

function ImGui:PopColour(index: string)
	Style.Colours[index] = table.clone(Style.Backup.Colours[index])
end

function ImGui:SameLine(spacing: number?)
	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()
	local drawCursor: Types.DrawCursor = elementFrame.DrawCursor

	drawCursor.Position = drawCursor.PreviousPosition
		+ Vector2.xAxis * ((spacing ~= nil) and (spacing > 0) and spacing or Style.Sizes.ItemSpacing.X)
	drawCursor.LineHeight = drawCursor.PreviousLineHeight
	drawCursor.TextLineOffset = drawCursor.PreviousTextLineOffset
	drawCursor.SameLine = true
end

function ImGui:AlignTextToFramePadding()
	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()
	local drawCursor: Types.DrawCursor = elementFrame.DrawCursor

	drawCursor.LineHeight = math.max(drawCursor.LineHeight, Style.Sizes.TextSize + 2 * Style.Sizes.FramePadding.Y)
	drawCursor.TextLineOffset = math.max(drawCursor.TextLineOffset, Style.Sizes.FramePadding.Y)
end

function ImGui:IsItemHovered()
	local window: Types.ImGuiWindow? = ImGuiInternal.CurrentWindow

	if window == nil then
		return false
	end

	if ImGuiInternal.HoveredWindow.Id ~= window.Id then
		return false
	end

	return false
end

--[[
	Manages the activity on the title bar excluding moving:
		- Checks for close and collapse buttons and updates accordingly.
		- Detects a double click on the title bar and collapses the window.
	
	The draw next frame argument is only used when the window collapses,
	since everything inside is culled.
]]
function ImGui:HandleWindowTitleBar(window: Types.ImGuiWindow)
	local focusOnButton: boolean = false

	-- Collapse button
	local collapse: Types.WindowTitleButton = window.Window.Title.Collapse
	if Flags.Enabled(window.Flags, Flags.WindowFlags.NoCollapse) == false and collapse.Instance ~= nil then
		local instance: ImageLabel = collapse.Instance

		local pressed: boolean, hovered: boolean, held: boolean =
			ButtonBehaviour(instance.AbsolutePosition, instance.AbsoluteSize, collapse.Id, collapse.Class, window)

		focusOnButton = pressed or hovered or held

		-- Setting the colour of the buttons
		-- Prevents a double call to update colour and transparency

		ButtonLogic(instance, hovered, held, collapse, 1, Style.ButtonStyles.TitleButton)

		-- The collapse button has been pressed
		if pressed == true then
			window.Collapsed = not window.Collapsed
			window.RedrawNextFrame = true
		end
	end

	-- Close button
	local close: Types.WindowTitleButton = window.Window.Title.Close
	if Flags.Enabled(window.Flags, Flags.WindowFlags.NoClose) == false and close.Instance ~= nil then
		local instance: ImageLabel = close.Instance

		local pressed: boolean, hovered: boolean, held: boolean =
			ButtonBehaviour(instance.AbsolutePosition, instance.AbsoluteSize, close.Id, close.Class, window)

		focusOnButton = pressed or hovered or held

		ButtonLogic(instance, hovered, held, close :: Types.Button, 1, Style.ButtonStyles.TitleButton)

		-- The close button has been pressed
		if pressed == true then
			window.Open[1] = false
			window.RedrawNextFrame = true
		end
	end

	-- Window background double click which will nto work when the window cannot collapse
	local title: Types.WindowTitle = window.Window.Title
	if
		(focusOnButton == false)
		and (title.Instance ~= nil)
		and (Flags.Enabled(window.Flags, Flags.WindowFlags.NoCollapse) == false)
	then
		local instance: Frame = title.Instance

		local hovered: boolean =
			ItemHoverable(instance.AbsolutePosition, instance.AbsoluteSize, title.Id, title.Class, window)

		if (hovered == true) and (ImGuiInternal.MouseButton1.ClicksThisFrame == 2) then
			window.Collapsed = not window.Collapsed
			window.RedrawNextFrame = true
			-- Have to draw it next frame because we have already done so this frame.
			-- Unlike Dear ImGui, we are relying on the absolute properties, so we can't detect a click before drawing for the frame.
		end
	end
end

--[[
	Manages the border of the window. Each side and the bottom two corners
	are frames which just get handled as any normal button would. None of the
	window moving actually happens here.
	I don't know how efficent this is, because there are lots of vector2 creations.
]]
function ImGui:HandleWindowBorder(window: Types.ImGuiWindow)
	if ImGuiInternal.ResizingWindow ~= nil then
		return
	end

	local position: Vector2 = window.Position
	local size: Vector2 = window.Size
	local mousePosition: Vector2 = ImGuiInternal.MouseCursor.Position

	local outerPadding: number = Style.Sizes.ResizeOuterPadding
	local innerPadding: number = Style.Sizes.ResizeInnerPadding
	local padding: number = outerPadding + innerPadding

	--[[
		Every resize is passed through here.
		Because the detection radius is greater than the visible edges of the window
		which highlight when you click, we can't use the absolute position in any
		helpful way.
	]]
	local function ResizeBehaviour(
		element: Types.ResizeElement,
		positionPadding: Vector2,
		resizeSize: Vector2,
		styleType: number,
		buttonStyle: Types.ButtonStyle,
		resize: Vector2,
		offset: Vector2
	)
		local _, hovered: boolean, held: boolean =
			ButtonBehaviour(position + positionPadding, resizeSize, element.Id, element.Class, window)

		ButtonLogic(element.Instance, hovered, held, element, styleType, buttonStyle)

		if held == true then
			ImGuiInternal.ResizingWindow = window
			ImGui:SetNavWindow(window)

			ImGuiInternal.ResizeSize = resize
			ImGuiInternal.HoldOffset = offset
		end
	end

	-- Top Side
	ResizeBehaviour(
		window.Window.Resize.Top,
		Vector2.new(innerPadding, -outerPadding),
		Vector2.new(size.X - 2 * padding, outerPadding * 2),
		0,
		Style.ButtonStyles.SideResize,
		-Vector2.yAxis,
		(mousePosition - position) * Vector2.yAxis
	)

	-- Bottom Side
	ResizeBehaviour(
		window.Window.Resize.Bottom,
		Vector2.new(innerPadding, -outerPadding + size.Y),
		Vector2.new(size.X - 2 * innerPadding, outerPadding * 2),
		0,
		Style.ButtonStyles.SideResize,
		Vector2.yAxis,
		(mousePosition - position - size) * Vector2.yAxis
	)

	-- Left Side
	ResizeBehaviour(
		window.Window.Resize.Left,
		Vector2.new(-outerPadding, innerPadding),
		Vector2.new(outerPadding * 2, size.Y - 2 * padding),
		0,
		Style.ButtonStyles.SideResize,
		-Vector2.xAxis,
		(mousePosition - position) * Vector2.xAxis
	)

	-- Right Side
	ResizeBehaviour(
		window.Window.Resize.Right,
		Vector2.new(-outerPadding + size.X, innerPadding),
		Vector2.new(outerPadding * 2, size.Y - 2 * innerPadding),
		0,
		Style.ButtonStyles.SideResize,
		Vector2.xAxis,
		(mousePosition - position - size) * Vector2.xAxis
	)

	-- Bottom Left Corner
	ResizeBehaviour(
		window.Window.Resize.BottomLeft,
		Vector2.new(-outerPadding, -innerPadding + size.Y),
		Vector2.one * padding,
		1,
		Style.ButtonStyles.CornerResize,
		Vector2.new(-1, 1),
		mousePosition - position - size * Vector2.yAxis
	)

	-- Bottom Right Corner
	ResizeBehaviour(
		window.Window.Resize.BottomRight,
		Vector2.new(-innerPadding + size.X, -innerPadding + size.Y),
		Vector2.one * padding,
		1,
		Style.ButtonStyles.CornerResizeVisible,
		Vector2.one,
		mousePosition - position - size
	)
end

function ImGui:UpdateWindowMove()
	local window: Types.ImGuiWindow? = ImGuiInternal.MovingWindow

	if window == nil then
		return
	end

	if ImGuiInternal.MouseButton1.Down == true then
		window.Position = ImGuiInternal.MouseCursor.Position - ImGuiInternal.HoldOffset
		window:UpdatePosition()
		ImGui:UpdateWindowFocusOrder(window)
		ImGui:SetActive("", "", nil)
	else
		ImGuiInternal.HoldOffset = Vector2.zero
		ImGuiInternal.MovingWindow = nil
		ImGui:SetActive("", "", nil)
	end
end

function ImGui:UpdateWindowResize()
	local window: Types.ImGuiWindow? = ImGuiInternal.ResizingWindow

	if window == nil then
		return
	end

	if ImGuiInternal.MouseButton1.Down == true then
		local position: Vector2 = window.Position
		local size: Vector2 = window.Size
		local minimumSize: Vector2 = window.MinimumSize
		local offset: Vector2 = ImGuiInternal.HoldOffset
		local resizeSize: Vector2 = ImGuiInternal.ResizeSize
		local screenSize: Vector2 = ImGuiInternal.ScreenSize
		local newPosition: Vector2 = position
		local newSize: Vector2 = size

		local mousePosition: Vector2 = ImGuiInternal.MouseCursor.Position

		if resizeSize.X > 0 then
			newSize = Vector2.new(
				math.clamp(mousePosition.X - position.X - offset.X, minimumSize.X, screenSize.X - position.X),
				newSize.Y
			)
		elseif resizeSize.X < 0 then
			newSize = Vector2.new(
				math.clamp(
					position.X + size.X - mousePosition.X + offset.X,
					minimumSize.X,
					screenSize.X - position.X - minimumSize.X
				),
				newSize.Y
			)
			newPosition = Vector2.new(
				math.clamp(mousePosition.X - offset.X, 0, position.X + size.X - minimumSize.X),
				newPosition.Y
			)
		end

		if resizeSize.Y > 0 then
			newSize = Vector2.new(
				newSize.X,
				math.clamp(mousePosition.Y - position.Y - offset.Y, minimumSize.Y, screenSize.Y - position.Y)
			)
		elseif resizeSize.Y < 0 then
			newSize = Vector2.new(
				newSize.X,
				math.clamp(
					position.Y + size.Y - mousePosition.Y + offset.Y,
					minimumSize.Y,
					screenSize.Y - position.Y - minimumSize.Y
				)
			)
			newPosition = Vector2.new(
				newPosition.X,
				math.clamp(mousePosition.Y - offset.Y, -offset.Y, position.Y + size.Y - minimumSize.Y)
			)
		end

		window.Position = newPosition
		window.Size = newSize

		window:UpdatePosition()
		window:UpdateSize()
	else
		ImGuiInternal.ResizingWindow = nil
		ImGuiInternal.HoldOffset = Vector2.zero
		ImGuiInternal.ResizeSize = Vector2.zero
		ImGui:SetActive("", "", nil)
	end
end

--[[
	CREATION FUNCTIONS

	Window functions

	:Begin()
	:End()

	Element functions

	:Text()
	:TextDisabled()
	:TextColoured()

	:Checkbox()
	:Button()

	:Indent()
	:UnIndent()
]]

--[[
	The main window creation. This will create the draggable, resizable windows for most operations
	but the creation of any popups, menus and other window objects will go through here.

	The flags property changes the behaviour of the window. However, most flags don't update exisiting
	behaviour. For example, if the flags change to have no title bar, the title bar won't be deleted
	but it won't be interactable. If you want to change flags for a window, skipping a frame to delete
	the window will draw a new window with the new flags. It's just simpler that way.
]]
function ImGui:Begin(windowName: string, open: { boolean }?, flags: Types.Flag | nil): boolean
	-- just create a set of default flags
	flags = flags or DefaultWindowFlags

	--[[
		If the window is not open at all because the open value is false then we return instantly
		this ensures that the window is not created at all since it will not be visible.
		Additionally, we do not need to check the window open value, since it is updated every frame
		and is equal to the open variable which is checked here.
	]]
	if (open ~= nil) and (open[1] == false) and (Flags.Enabled(flags, Flags.WindowFlags.NoClose) == false) then
		return false
	end

	--[[
		If the window already exists we use it again. It keeps all elements from the previous frame.
		Otherwise we create a new empty window.
	]]
	local previousWindow: Types.ImGuiWindow? = ImGui:GetWindowById(windowName)
	local window: Types.ImGuiWindow = previousWindow or ImGui:CreateWindow(windowName, flags)

	local firstFrameCall: boolean = (window.LastFrameActive ~= startFrameId) -- If this is the first time in the renderstep for creating the window
	local windowApearing: boolean = (window.LastFrameActive < (startFrameId - 1))
		or (Flags.Enabled(flags, Flags.WindowFlags.Popup) == true)

	--[[
		The parent window if this begin is called within another window. It can be nil
	]]
	local parentWindowFromStack: Types.ImGuiWindow = ImGuiInternal.WindowStack[#ImGuiInternal.WindowStack] -- the last used window in the stack
	local parentWindow: Types.ImGuiWindow? = firstFrameCall and parentWindowFromStack or window.ParentWindow -- either the stack window or the window's parent

	--[[
		No we are ready to add the window to the stack and set as the current window.
		Any additional window data is also updated.
	]]
	table.insert(ImGuiInternal.WindowStack, window)
	ImGuiInternal.CurrentWindow = window
	table.insert(ImGuiInternal.ElementFrameStack, window.Window.Frame) -- append the window frame to the elementframe stack. Sets the next draw position to the window frame.
	window.Appearing = windowApearing
	window.LastFrameActive = startFrameId
	ImGuiInternal.ActiveWindow = window

	if Flags.Enabled(flags, Flags.WindowFlags.ChildWindow) == true then
		ImGuiInternal.ChildWindowCount += 1
	end

	--[[
		If it's the first call this frame, then we draw the window and set any data. Any changes
		won't propogate until the next frame.
	]]
	if firstFrameCall == true then
		window.Flags = flags
		-- local tooltip: boolean = (flags.ChildWindow == true) and (flags.Tooltip == true)

		ImGui:UpdateWindowLinks(window, flags, parentWindow)
		window.ParentWindowFromStack = parentWindowFromStack
		window.Active = true
		window.Open = open or { true } -- We default to open. Closed would be unhelpful.

		if Flags.Enabled(flags, Flags.WindowFlags.ChildWindow) == true then
			table.insert(parentWindow.ChildWindows, window)
		end

		window:DrawWindow() -- Just a window shell.

		if Flags.Enabled(flags, Flags.WindowFlags.NoTitleBar) == false then
			window:DrawTitle()
			ImGui:HandleWindowTitleBar(window)
		end

		if (Flags.Enabled(flags, Flags.WindowFlags.NoResize) == false) and (window.Collapsed == false) then
			ImGui:HandleWindowBorder(window)
		end

		--[[
			This draws the actual ElementFrame for the elements to sit in.
		]]
		window:DrawFrame()
	end

	-- A lot of internal code in here!

	--[[
		If the window is collapsed or not visible or will be redrawn next frame, there is no point
		adding elements to the window. Anything colled within can be skipped
	]]
	local skipElements: boolean = (window.Collapsed == true)
		or (window.Active == false)
		or (window.Open[1] == false)
		or (window.RedrawNextFrame == true)
	window.SkipElements = skipElements

	--[[
		Based on the issue about when to end elements, because this window can have no child
		elements we end it entirely.
	]]
	if skipElements == true then
		ImGui:End()
	end

	return not skipElements
end

--[[
	Finishes with the current window. Must be called only if the :Begin() returns true.
]]
function ImGui:End()
	assert((#ImGuiInternal.WindowStack > 0), "Called :End() to many times!")
	assert(ImGuiInternal.CurrentWindow ~= nil, "Never called :Begin() to set a current window!")

	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow
	local flags: Types.Flag = window.Flags

	if Flags.Enabled(flags, Flags.WindowFlags.ChildWindow) == true then
		ImGuiInternal.ChildWindowCount -= 1
	end

	--[[
		Every stack gets popped and changes the current window.
	]]
	table.remove(ImGuiInternal.WindowStack)
	ImGuiInternal.CurrentWindow = ImGuiInternal.WindowStack[#ImGuiInternal.WindowStack]
	table.remove(ImGuiInternal.ElementFrameStack)
end

function ImGui:BeginMenuBar()
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow
	assert(window.Window.Menubar.Appending == false, ImGuiInternal.ErrorMessages.MenuBarOpen)

	-- see ImGui:Text()
	if
		(window.Collapsed == true)
		or (window.Open[1] == false)
		or (window.RedrawNextFrame == true)
		or (Flags.Enabled(window.Flags, Flags.WindowFlags.MenuBar) == false)
	then
		return false
	end

	window.Window.Menubar.Appending = true
	window:DrawMenuBar()

	return true
end

function ImGui:EndMenuBar()
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow
	assert(window.Window.Menubar.Appending == true, ImGuiInternal.ErrorMessages.MenuBarClosed)

	-- see ImGui:Text()
	if
		(window.Collapsed == true)
		or (window.Open[1] == false)
		or (window.RedrawNextFrame == true)
		or (Flags.Enabled(window.Flags, Flags.WindowFlags.MenuBar) == false)
	then
		return
	end

	window.Window.Menubar.Appending = false
end

function ImGui:BeginMenu(name: string)
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow
	assert(window.Window.Menubar.Appending == true, ImGuiInternal.ErrorMessages.MenuBarOpen)
	assert(window.ActiveMenu == nil, ImGuiInternal.ErrorMessages.ActiveMenuOpen)

	-- see ImGui:Text()
	if window.SkipElements == true then
		return false
	end

	local menubar: Types.WindowMenubar = window.Window.Menubar

	local menu: Types.ImGuiMenu? = menubar.Menus[name]
	if menu == nil then
		menu = Menu.new(name, window, menubar)
		menu:DrawMenu(menubar.DrawCursor.Position)
		menubar.Menus[name] = menu
		menubar.DrawCursor.PreviousPosition = menubar.DrawCursor.Position
		menubar.DrawCursor.Position += Vector2.xAxis * menu.Size.X
	else
		menu:UpdatePosition(menubar.DrawCursor.Position)
		menubar.DrawCursor.PreviousPosition = menubar.DrawCursor.Position
		menubar.DrawCursor.Position += Vector2.xAxis * menu.Size.X
	end

	menu.Active = true
	menu.LastFrameActive = startFrameId

	-- local menuOpen: boolean = menu.Open

	local instance: TextLabel = menu.Instance
	local pressed: boolean, hovered: boolean, held: boolean =
		ButtonBehaviour(instance.AbsolutePosition, instance.AbsoluteSize, menu.Id, menu.Class, window)

	ButtonLogic(instance, hovered, held, menu :: Types.Button, 0, Style.ButtonStyles.Menu)

	if pressed == true then
		window.ActiveMenu = menu
		return true
	end
	return false
end

function ImGui:EndMenu()
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow
	assert(window.Window.Menubar.Appending == true, ImGuiInternal.ErrorMessages.MenuBarOpen)
	assert(window.ActiveMenu, ImGuiInternal.ErrorMessages.ActiveMenuClosed)

	if (window.Collapsed == true) or (window.Open[1] == false) or (window.RedrawNextFrame == true) then
		return false
	end

	window.ActiveMenu = nil
end

--[[
	Text Functions:

		There are multiple text functions which all ultimately call the same :TextV() function.
		The :TextV() function draws all the elements and has to change properties depending on
		the type of text element to draw.
		
		The :TextDisabled() is the :TextColoured function and they both just use the :Push and
		:PopColour() functions to change the style. :BulletText() is a bit different since it
		enables the .BulletText flag to change the behaviour.
]]

function ImGui:Text(textString: string, ...: any)
	ImGui:_Text(DefaultTextFlags, textString, ...)
end

function ImGui:ChangingText(id: Types.ImGuiId, textString: string, ...: any)
	ImGui:PushId(id)
	ImGui:_Text(DefaultTextFlags, textString, ...)
end

function ImGui:TextDisabled(textString: string, ...: any)
	ImGui:TextColoured(Style.Colours.TextDisabled, textString, ...)
end

function ImGui:TextColoured(colour: Types.Colour4, textString: string, ...: any)
	ImGui:PushColour("Text", colour)
	ImGui:_Text(DefaultTextFlags, textString, ...)
	ImGui:PopColour("Text")
end

function ImGui:BulletText(textString: string, ...: any)
	ImGui:_Text(BulletTextFlags, textString, ...)
end

function ImGui:_Text(flags: Types.Flag, textString: string, ...: any)
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	--[[
		We don't draw if it is going to be redrawn next frame.
		Don't remove because the text is parented to an instance and when it redraws next frame
		the instance is destroyed so the text only appears for a frame and is then destroyed
		so we don't draw at all.
	]]
	if window.SkipElements == true then
		return
	end

	--[[
		IMPORTANT:
			This whole passage regards whether elements should be drawn even if they are not visible
			because the scrolling is incorrect. When this was implemented, windows could not be scrolled
			and therefore it was easy enough to just cull any item below the current window height. However,
			this will not work with scrolling so it's no longer part of the window.
		
	-- There's no point drawing the element if it's too far down a window to be visible.
	-- The windows are unlikely to be resized up and down repeatedly so it saves memory and time
	-- by exiting at the start.
	-- There's no point checking horizontally because it's unlikely that anything will be too far
	-- and it's not worth it for now.
	-- This will need to be changed when window scrolling is added.
	if
		elementFrame.DrawCursor.Position.Y
		> math.max(elementFrame.Instance.AbsoluteSize.Y, window.Window.Frame.Instance.AbsoluteSize.Y)
	then
		-- Since we still want to have scrolling the draw cursor will be incremented. Any element
		-- local height: number = Style.Sizes.TextSize + Style.Sizes.ItemSpacing.Y
		-- if textString:find("\n") then
		-- 	height = Utility.CalculateTextSize(textString).Y + Style.Sizes.ItemSpacing.Y
		-- end
		-- elementFrame.DrawCursor.PreviousPosition = elementFrame.DrawCursor.Position
		-- elementFrame.DrawCursor.Position += Vector2.yAxis * height
		return
	end
	]]

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	--[[
		If any additional paramaters are passed then they are formatted.
	]]
	if #{ ... } > 0 then
		textString = textString:format(...)
	end

	--[[
		If a previous version already exists from the last frame then we use it since it already
		has all the data we need.

		If the NextItemData contains an id then it must be used over the generated version. But it
		is still appended to the element frame to ensure comptability. I don't think there's anytime
		when you would not want that.
	]]
	local text: Types.ImGuiText? = ImGui:GetElementById(
		elementFrame.Id .. ">" .. (ImGuiInternal.NextItemData.Id or textString),
		Flags.Enabled(flags, Flags.TextFlags.BulletText) == true and "BulletText" or "Text",
		elementFrame
	)

	--[[
		If it does not already exist then we create a new one, draw it and then add it to the elements
		in the ElementFrame. If it does exist, we just change position.

		The :DrawText() and :UpdatePosition() methods pass through the position to draw to. Normally, it
		would just be the DrawCursor position, but since it is a text element, we have an additional
		property to adjust the vertical offset when elements are aligned on the same line. This prevents
		the text being too high relative to other elements with frame padding, such as buttons and checkboxes.
	]]
	if text == nil then
		text = Text.new(textString, window, elementFrame, flags)
		text:DrawText(elementFrame.DrawCursor.Position + Vector2.yAxis * elementFrame.DrawCursor.TextLineOffset)
		table.insert(elementFrame.Elements, text)
	else
		if text.Text ~= textString then
			text:UpdateText(textString)
		end

		text:UpdatePosition(elementFrame.DrawCursor.Position + Vector2.yAxis * elementFrame.DrawCursor.TextLineOffset)
	end

	--[[
		We pass the size of the text into the ItemSize() function which moves the draw cursor for the next
		element. We can just use the Size property of the text element since it doesn't change once drawn.
	]]
	ItemSize(elementFrame.DrawCursor, text.Size)

	text.Active = true
	text.LastFrameActive = startFrameId
	ImGuiInternal:ResetNextItemData()
end

--[[
	Interactive Buttons:

		Most elements can be interacted with and will return a boolean value or number to
		show whether they have been interacted with.
]]
function ImGui:Checkbox(text: string, value: { boolean }): boolean
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:_Text()
	if window.SkipElements == true then
		return false
	end

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	local checkbox: Types.ImGuiCheckbox? =
		ImGui:GetElementById(elementFrame.Id .. ">" .. text, "Checkbox", elementFrame)

	if checkbox == nil then
		checkbox = Checkbox.new(text, value, window, elementFrame)
		checkbox:DrawCheckbox(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, checkbox)
	else
		checkbox:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	ItemSize(elementFrame.DrawCursor, checkbox.Size)

	checkbox.Active = true
	checkbox.LastFrameActive = startFrameId

	local pressed: boolean, hovered: boolean, held: boolean =
		ButtonBehaviour(checkbox.Instance.AbsolutePosition, checkbox.Size, checkbox.Id, checkbox.Class, window)

	ButtonLogic(checkbox.Instance.checkbox, hovered, held, checkbox, 0, Style.ButtonStyles.Frame)

	if pressed == true then
		value[1] = not value[1]
	end

	checkbox:UpdateCheckmark()

	if pressed == true then
		return true
	end
	return false
end

function ImGui:Button(text: string): boolean
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:_Text()
	if window.SkipElements == true then
		return false
	end

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	local button: Types.ImGuiButton? = ImGui:GetElementById(elementFrame.Id .. ">" .. text, "Button", elementFrame)

	if button == nil then
		button = Button.new(text, window, elementFrame)
		button:DrawButton(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, button)
	else
		button:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	ItemSize(elementFrame.DrawCursor, button.Size, Style.Sizes.FramePadding.Y)

	button.Active = true
	button.LastFrameActive = startFrameId

	local pressed: boolean, hovered: boolean, held: boolean =
		ButtonBehaviour(button.Instance.AbsolutePosition, button.Size, button.Id, button.Class, window)

	ButtonLogic(button.Instance, hovered, held, button, 0, Style.ButtonStyles.Button)

	if pressed == true then
		return true
	end
	return false
end

function ImGui:RadioButton(text: string, value: { number }, buttonValue: number): boolean
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:_Text()
	if window.SkipElements == true then
		return value[1] == buttonValue
	end

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	local radioButton: Types.ImGuiRadioButton? =
		ImGui:GetElementById(elementFrame.Id .. ">" .. text, "RadioButton", elementFrame)

	if radioButton == nil then
		radioButton = RadioButton.new(text, buttonValue, value, window, elementFrame)
		radioButton:DrawRadioButton(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, radioButton)
	else
		radioButton:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	ItemSize(elementFrame.DrawCursor, radioButton.Size)

	radioButton.Active = true
	radioButton.LastFrameActive = startFrameId

	local pressed: boolean, hovered: boolean, held: boolean = ButtonBehaviour(
		radioButton.Instance.AbsolutePosition,
		radioButton.Size,
		radioButton.Id,
		radioButton.Class,
		window
	)

	ButtonLogic(radioButton.Instance.radio, hovered, held, radioButton, 1, Style.ButtonStyles.Frame)

	if pressed == true then
		value[1] = buttonValue
	end

	radioButton:UpdateRadioButton()

	if pressed == true then
		return true
	end
	return false
end

function ImGui:LabelText(text: string, label: string)
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:_Text()
	if window.SkipElements == true then
		return
	end

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	local labelText: Types.ImGuiLabelText? =
		ImGui:GetElementById(elementFrame.Id .. ">" .. text .. "|" .. label, "LabelText", elementFrame)

	if labelText == nil then
		labelText = LabelText.new(text, label, window, elementFrame)
		labelText:DrawLabelText(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, labelText)
	else
		labelText:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	ItemSize(elementFrame.DrawCursor, labelText.Instance.AbsoluteSize)

	labelText.Active = true
	labelText.LastFrameActive = startFrameId
end

function ImGui:InputText(label: string, value: { string })
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:_Text()
	if window.SkipElements == true then
		return
	end

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()
	local inputText: Types.ImGuiInputText? =
		ImGui:GetElementById(elementFrame.Id .. ">" .. label, "InputText", elementFrame)

	if inputText == nil then
		inputText = InputText.new(label, value, window, elementFrame)
		inputText:DrawInputText(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, inputText)
	else
		inputText:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	ItemSize(elementFrame.DrawCursor, inputText.Instance.AbsoluteSize)

	inputText.Active = true
	inputText.LastFrameActive = startFrameId
end

function ImGui:Separator()
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:_Text()
	if window.SkipElements == true then
		return
	end

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	local separator: Types.ImGuiSeparator? = ImGui:GetElementById("", "Separator", elementFrame, true)

	if separator == nil then
		separator = {
			Class = "Separator",
			Id = "",
		} :: Types.ImGuiSeparator
		local instance: Frame = Instance.new("Frame")
		instance.Name = "separator"
		instance.Size = UDim2.new(1, 0, 0, 1)

		instance.BackgroundColor3 = Style.Colours.Separator.Colour
		instance.BackgroundTransparency = Style.Colours.Separator.Transparency
		instance.BorderColor3 = COLOUR3_BLACK
		instance.BorderSizePixel = 0

		instance.Parent = elementFrame.Instance
		separator.Instance = instance

		table.insert(elementFrame.Elements, separator)
	end

	separator.Instance.Position = UDim2.fromOffset(0, elementFrame.DrawCursor.Position.Y)
	ItemSize(elementFrame.DrawCursor, separator.Instance.AbsoluteSize)

	separator.Active = true
	separator.LastFrameActive = startFrameId
end

function ImGui:Indent(width: number?)
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local frame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	frame.DrawCursor.Indent += width or Style.Sizes.IndentSpacing
	frame.DrawCursor.Position += Vector2.xAxis * (width or Style.Sizes.IndentSpacing)
end

function ImGui:Unindent(width: number?)
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local frame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	frame.DrawCursor.Indent -= width or Style.Sizes.IndentSpacing
	frame.DrawCursor.Position -= Vector2.xAxis * (width or Style.Sizes.IndentSpacing)
end

function ImGui:TreeNode(text: string): boolean
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow? = ImGuiInternal.CurrentWindow

	-- see ImGui:_Text()
	if window.SkipElements == true then
		return false
	end

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	local treenode: Types.ImGuiTreeNode? =
		ImGui:GetElementById(elementFrame.Id .. ">" .. text, "TreeNode", elementFrame, true)

	if treenode == nil then
		treenode = TreeNode.new(text, { false }, window, elementFrame)
		treenode:DrawTreeNode(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, treenode)
	else
		treenode:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	ItemSize(elementFrame.DrawCursor, treenode.Size)

	treenode.Active = true
	treenode.LastFrameActive = startFrameId

	local pressed: boolean, hovered: boolean, held: boolean =
		ButtonBehaviour(treenode.Instance.AbsolutePosition, treenode.Size, treenode.Id, treenode.Class, window)

	ButtonLogic(treenode.Instance, hovered, held, treenode, 0, Style.ButtonStyles.TreeNode)
	treenode:UpdateTreeNode(pressed)

	if treenode.Value[1] == true then
		ImGui:Indent(Style.Sizes.IndentSpacing)
		return true
	else
		return false
	end
end

function ImGui:TreePop()
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	if window.SkipElements == true then
		return
	end

	ImGui:Unindent(Style.Sizes.IndentSpacing)
end

function ImGui:CollapsingHeader(text: string, value: { boolean }?): boolean
	assert(ImGuiInternal.CurrentWindow, ImGuiInternal.ErrorMessages.CurrentWindow)
	assert(#ImGuiInternal.ElementFrameStack > 0, ImGuiInternal.ErrorMessages.ElementFrame)
	local window: Types.ImGuiWindow? = ImGuiInternal.CurrentWindow

	-- see ImGui:_Text()
	if window.SkipElements == true then
		return false
	end

	local elementFrame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	local header: Types.ImGuiHeader? =
		ImGui:GetElementById(elementFrame.Id .. ">" .. text, "CollapsingHeader", elementFrame, true)

	if header == nil then
		header = Header.new(text, value or { false }, window, elementFrame)
		header:DrawHeader(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, header)
	else
		header:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	ItemSize(elementFrame.DrawCursor, header.Instance.AbsoluteSize)

	header.Active = true
	header.LastFrameActive = startFrameId

	local pressed: boolean, hovered: boolean, held: boolean =
		ButtonBehaviour(header.Instance.AbsolutePosition, header.Instance.AbsoluteSize, header.Id, header.Class, window)

	ButtonLogic(header.Instance, hovered, held, header, 0, Style.ButtonStyles.CollapsingHeader)
	header:UpdateHeader(pressed)

	if header.Value[1] == true then
		return true
	else
		return false
	end
end

return ImGui
