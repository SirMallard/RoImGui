local HttpService = game:GetService("HttpService")
local runService: RunService = game:GetService("RunService")

local components = script.Components
local Types = require(script.Types)
local ImGuiInternal: Types.ImGuiInternal = require(script.ImGuiInternal)
local Window = require(components.Window)
local Text = require(components.Text)
local Checkbox = require(components.Checkbox)
local Button = require(components.Button)
local Style = require(script.Utility.Style)
local Utility = require(script.Utility.Utility)
local Flags = require(script.Flags)

local startFrameId: number = -1
local endFrameId: number = -1

local ImGui: Types.ImGui = {} :: Types.ImGui

ImGui.FrameId = startFrameId
ImGui.Flags = Flags
ImGui.Types = script.Types
ImGui.Colour4 = script.Utility.Colour4

function ImGui:DebugWindow()
	local flags: Types.WindowFlags = Flags.WindowFlags()
	flags.NoClose = true
	-- flags.NoCollapse = true

	-- if ImGui:Begin("Debug", { true }, flags) then
	-- ImGui:Text("Elements:")
	-- ImGui:Indent()
	-- ImGui:Text("ActiveID: %s", ImGuiInternal.ActiveId or "NONE")
	-- ImGui:Text("HoverID: %s", ImGuiInternal.HoverId or "NONE")
	-- ImGui:Unindent()

	-- ImGui:Text("Windows:")
	-- ImGui:Indent()
	-- ImGui:Text("Active Window: %s", ImGuiInternal.ActiveWindow and ImGuiInternal.ActiveWindow.Id or "NONE")
	-- ImGui:Text("Hovered Window: %s", ImGuiInternal.HoveredWindow and ImGuiInternal.HoveredWindow.Id or "NONE")
	-- ImGui:Text("Moving Window: %s", ImGuiInternal.MovingWindow and ImGuiInternal.MovingWindow.Id or "NONE")
	-- ImGui:Text("Nav Window: %s", ImGuiInternal.NavWindow and ImGuiInternal.NavWindow.Id or "NONE")
	-- ImGui:Text("Resizing WIndow: %s", ImGuiInternal.ResizingWindow and ImGuiInternal.ResizingWindow.Id or "NONE")
	-- ImGui:Unindent()
	-- ImGui:Text("Resizing:")
	-- ImGui:Indent()
	-- ImGui:Text("Mouse Position: (%s)", ImGuiInternal.MouseCursor.Position)
	-- ImGui:Text("Mouse Delta: (%s)", ImGuiInternal.MouseCursor.Delta)
	-- ImGui:Text("Hold Offset: (%s)", ImGuiInternal.HoldOffset)
	-- ImGui:Unindent()
	-- ImGui:Checkbox("Show Item Picker", ImGuiInternal.Debug.HoverDebug)
	-- 	ImGui:End()
	-- end

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
		-- ImGui:DebugWindow()

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
		for name: string, menubar: Types.WindowMenu in window.Window.Menubar.Menus do
			menubar.Id = name
			-- menubar.WasActive = menubar.Active
			-- menubar.Active = false

			-- if menubar.WasActive == false then
			-- 	if menubar.Instance ~= nil then
			-- 		menubar.Instance:Destroy()
			-- 	end
			-- 	window.Window.Menubar.Menus[name] = nil
			-- end
		end

		-- loop through all window elements
		local frame: Types.ElementFrame = window.Window.Frame

		for elementIndex: number, element: Types.Element in frame.Elements do
			if element.LastFrameActive < endFrameId then
				element:Destroy()
				table.remove(frame.Elements, elementIndex)
			else
				-- if element.Class == "Text" and element.Text:sub(1, 14) == "Mouse Position" then
				-- 	print(frameId, element.Text:sub(17))
				-- end
				element.Active = false
			end
		end

		frame.DrawCursor.Position = frame.DrawCursor.StartPosition
		frame.DrawCursor.PreviousPosition = frame.DrawCursor.StartPosition

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

		if window.Flags.NoResize == true then
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
function ImGui:UpdateWindowLinks(window: Types.ImGuiWindow, flags: Types.WindowFlags, parentWindow: Types.ImGuiWindow?)
	window.ParentWindow = parentWindow
	window.RootWindow, window.PopupRootWindow, window.PopupParentRootWindow = window, window, window
	if (parentWindow ~= nil) and (flags.ChildWindow == true) and not (flags.Tooltip == true) then
		window.RootWindow = parentWindow.RootWindow
	end
	if (parentWindow ~= nil) and (flags.Popup == true) then
		window.PopupRootWindow = parentWindow.PopupRootWindow
	end
	if (parentWindow ~= nil) and not (flags.Modal == true) and (flags.ChildWindow == true or flags.Popup == true) then
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
	class: Types.Class,
	window: Types.ImGuiWindow
)
	if (ImGuiInternal.HoverId ~= "") and ((ImGuiInternal.HoverId ~= id) and (ImGuiInternal.HoverClass ~= class)) then
		return false
	end

	if ImGuiInternal.HoveredWindow ~= window then
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
	class: Types.Class,
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
	Additional functions

]]

function ImGui:GetWindowById(windowName: string): (Types.ImGuiWindow?)
	return ImGuiInternal.Windows[windowName] or nil
end

function ImGui:CreateWindow(windowName: string, flags: Types.WindowFlags): (Types.ImGuiWindow)
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

function ImGui:SetActive(id: Types.ImGuiId, class: Types.Class, window: Types.ImGuiWindow | nil)
	ImGuiInternal.ActiveId = id
	ImGuiInternal.ActiveClass = class
	ImGuiInternal.ActiveWindow = window
end

function ImGui:SetHover(id: Types.ImGuiId, class: Types.Class)
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
): (Types.Element?)
	local element: Types.Element

	for _, childElement: Types.ImGuiText in elementFrame.Elements do
		if
			(childElement.Id == id)
			and (childElement.Class == class)
			and ((childElement.Active == false) or (active == nil))
		then
			element = childElement
			break
		end
	end

	return element
end

function ImGui:PushColour(index: string, colour: Types.Colour4)
	Style.Colours[index] = colour
end

function ImGui:PopColour(index: string)
	Style.Colours[index] = table.clone(Style.Backup.Colours[index])
end

--[[
	Manages the activity on the title bar excluding moving:
		- Checks for close and collapse buttons and updates accordingly.
		- Detects a double click on the title bar and collapses the window.
]]
function ImGui:HandleWindowTitleBar(window: Types.ImGuiWindow)
	local focusOnButton: boolean = false

	-- Collapse button
	local collapse: Types.WindowTitleButton = window.Window.Title.Collapse
	if window.Flags.NoCollapse == false and collapse.Instance ~= nil then
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
	if window.Flags.NoClose == false and close.Instance ~= nil then
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
	if (focusOnButton == false) and (title.Instance ~= nil) and (window.Flags.NoCollapse == false) then
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
function ImGui:Begin(windowName: string, open: { boolean }?, flags: Types.WindowFlags | nil): (boolean)
	-- just create a set of default flags
	flags = flags or Flags.WindowFlags()

	-- if the window is not open at all because the open value is false then we return instantly
	-- this ensures that the window is not created at all since it will not be visible
	-- additionally, we do not need to check the window open value, since it is updated every frame
	-- and is equal to the open variable which is checked here
	if (open ~= nil) and (open[1] == false) and (flags.NoClose == false) then
		return false
	end

	-- grab the previous window if we have already created one, else we create a new one
	-- therefore, we are not preserving state between frames
	local previousWindow: Types.ImGuiWindow? = ImGui:GetWindowById(windowName)
	local window: Types.ImGuiWindow = previousWindow or ImGui:CreateWindow(windowName, flags)

	local firstFrameCall: boolean = (window.LastFrameActive ~= startFrameId) -- If this is the first time in the renderstep for creating the window
	local windowApearing: boolean = (window.LastFrameActive < (startFrameId - 1)) or (flags.Popup == true)

	local parentWindowFromStack: Types.ImGuiWindow = ImGuiInternal.WindowStack[#ImGuiInternal.WindowStack] -- the last used window in the stack
	local parentWindow: Types.ImGuiWindow? = firstFrameCall and parentWindowFromStack or window.ParentWindow -- either the stack window or the window's parent

	table.insert(ImGuiInternal.WindowStack, window)
	ImGuiInternal.CurrentWindow = window
	table.insert(ImGuiInternal.ElementFrameStack, window.Window.Frame) -- append the window frame to the elementframe stack. Sets the next draw position to the window frame.
	window.Appearing = windowApearing
	window.LastFrameActive = startFrameId
	ImGuiInternal.ActiveWindow = window

	if flags.ChildWindow == true then
		ImGuiInternal.ChildWindowCount += 1
	end

	if flags.Popup == true then
		print("Popup window created!")
	end

	-- don't know why exactly, but it doesn't seem to be an issue.
	-- if ((window.Open[1] == false) and (flags.NoClose == false)) or (flags.Collapsed == true) then
	-- 	window.Collapsed = true
	-- end

	if firstFrameCall == true then
		window.Flags = flags
		-- local tooltip: boolean = (flags.ChildWindow == true) and (flags.Tooltip == true)

		ImGui:UpdateWindowLinks(window, flags, parentWindow)
		window.ParentWindowFromStack = parentWindowFromStack
		window.Active = true
		window.Open = open or { true } -- we default to

		-- if (flags.NoTitleBar == false) and (flags.NoCollapse == false) then
		-- end

		-- if windowApearing == true then
		-- 	if (flags.Popup == true) and (flags.Modal == false) then
		-- 	end
		-- end

		if flags.ChildWindow == true then
			table.insert(parentWindow.ChildWindows, window)
		end

		window:DrawWindow()

		if flags.NoTitleBar == false then
			window:DrawTitle()
			ImGui:HandleWindowTitleBar(window)
		end

		if (flags.NoResize == false) and (window.Collapsed == false) then
			ImGui:HandleWindowBorder(window)
		end

		window:DrawFrame()
	end

	-- A lot of internal code in here!

	-- if the window is not active, not sure if it can be false or the window is collapsed
	-- collapsing will still render the title bar which is why we go through all of this process.
	local skipElements: boolean = (window.Collapsed == true) or (window.Active == false)
	window.SkipElements = skipElements

	-- based on the issue about when to end elements, because this window can have no child
	-- elements we end it entirely.
	if skipElements == true then
		ImGui:End()
	end

	return not skipElements
end

function ImGui:End()
	assert((#ImGuiInternal.WindowStack > 0), "Called :End() to many times!")
	assert(ImGuiInternal.CurrentWindow ~= nil, "Never called :Begin() to set a current window!")

	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow
	local flags: Types.WindowFlags = window.Flags

	if flags.ChildWindow == true then
		ImGuiInternal.ChildWindowCount -= 1
	end

	table.remove(ImGuiInternal.WindowStack)
	ImGuiInternal.CurrentWindow = ImGuiInternal.WindowStack[#ImGuiInternal.WindowStack]
	table.remove(ImGuiInternal.ElementFrameStack)
end

function ImGui:Text(textString: string, ...: any)
	ImGui:TextV(textString, false, ...)
end

function ImGui:TextV(textString: string, bulletText: boolean, ...: any)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- We don't draw if it is going to be redrawn next frame.
	-- Don't remove because the text is parented to an instance and when it redraws next frame
	-- the instance is destroyed so the text only appears for a frame and is then destroyed
	-- so we don't draw at all.
	-- Settings the text to redraw next frame would already happen, so why render at all.
	if (window.Collapsed == true) or (window.Open[1] == false) or (window.RedrawNextFrame == true) then
		return
	end

	local elementFrame: Types.ElementFrame? = ImGui:GetActiveElementFrame()
	if elementFrame == nil then
		return
	end

	if
		elementFrame.DrawCursor.Position.Y
		> math.max(elementFrame.Instance.AbsoluteSize.Y, window.Window.Frame.Instance.AbsoluteSize.Y)
	then
		return
	end

	-- format with the args
	local args: { any } = { ... }
	if #args > 0 then
		for index: number, arg: any in args do
			args[index] = tostring(arg)
		end
		textString = textString:format(table.unpack(args))
	end

	local text: Types.ImGuiText? = ImGui:GetElementById(
		elementFrame.Id .. ">" .. textString,
		bulletText == true and "BulletText" or "Text",
		elementFrame
	)

	if text == nil then
		text = Text.new(textString, bulletText, window, elementFrame)
		text:DrawText(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, text)
	else
		text:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	text.Active = true
	text.LastFrameActive = startFrameId

	elementFrame.DrawCursor.PreviousPosition = elementFrame.DrawCursor.Position
	elementFrame.DrawCursor.Position += Vector2.new(0, text.Size.Y + Style.Sizes.ItemSpacing.Y)
end

function ImGui:TextDisabled(textString: string, ...: any)
	ImGui:PushColour("Text", Style.Colours.TextDisabled)
	ImGui:TextV(textString, false, ...)
	ImGui:PopColour("Text")
end

function ImGui:TextColoured(colour: Types.Colour4, textString: string, ...: any)
	ImGui:PushColour("Text", colour)
	ImGui:TextV(textString, false, ...)
	ImGui:PopColour("Text")
end

function ImGui:BulletText(textString: string, ...: any)
	ImGui:TextV(textString, true, ...)
end

function ImGui:Checkbox(text: string, value: { boolean })
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:Text()
	if (window.Collapsed == true) or (window.Open[1] == false) or (window.RedrawNextFrame == true) then
		return
	end

	local elementFrame: Types.ElementFrame? = ImGui:GetActiveElementFrame()
	if elementFrame == nil then
		return
	end

	if
		elementFrame.DrawCursor.Position.Y
		> math.max(elementFrame.Instance.AbsoluteSize.Y, window.Window.Frame.Instance.AbsoluteSize.Y)
	then
		return
	end

	local checkbox: Types.ImGuiCheckbox? =
		ImGui:GetElementById(elementFrame.Id .. ">" .. text, "Checkbox", elementFrame)

	if checkbox == nil then
		checkbox = Checkbox.new(text, value, window, elementFrame)
		checkbox:DrawCheckbox(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, checkbox)
	else
		checkbox:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	checkbox.Active = true
	checkbox.LastFrameActive = startFrameId

	local instance: Frame = checkbox.Instance

	local pressed: boolean, hovered: boolean, held: boolean =
		ButtonBehaviour(instance.AbsolutePosition, instance.AbsoluteSize, checkbox.Id, checkbox.Class, window)

	ButtonLogic(instance.checkbox, hovered, held, checkbox :: Types.Button, 0, Style.ButtonStyles.Checkbox)

	checkbox:UpdateCheckmark(pressed)

	elementFrame.DrawCursor.PreviousPosition = elementFrame.DrawCursor.PreviousPosition
	elementFrame.DrawCursor.Position += Vector2.new(0, checkbox.Size.Y + Style.Sizes.ItemSpacing.Y)
end

function ImGui:Button(text: string): (boolean)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:Text()
	if (window.Collapsed == true) or (window.Open[1] == false) or (window.RedrawNextFrame == true) then
		return false
	end

	local elementFrame: Types.ElementFrame? = ImGui:GetActiveElementFrame()
	if elementFrame == nil then
		return false
	end

	if
		elementFrame.DrawCursor.Position.Y
		> math.max(elementFrame.Instance.AbsoluteSize.Y, window.Window.Frame.Instance.AbsoluteSize.Y)
	then
		return false
	end

	local button: Types.ImGuiButton? = ImGui:GetElementById(elementFrame.Id .. ">" .. text, "Button", elementFrame)

	if button == nil then
		button = Button.new(text, window, elementFrame)
		button:DrawButton(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, button)
	else
		button:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	button.Active = true
	button.LastFrameActive = startFrameId

	local instance: TextLabel = button.Instance

	local pressed: boolean, hovered: boolean, held: boolean =
		ButtonBehaviour(instance.AbsolutePosition, instance.AbsoluteSize, button.Id, button.Class, window)

	ButtonLogic(instance, hovered, held, button :: Types.Button, 0, Style.ButtonStyles.Button)

	elementFrame.DrawCursor.PreviousPosition = elementFrame.DrawCursor.PreviousPosition
	elementFrame.DrawCursor.Position += Vector2.new(0, button.Size.Y + Style.Sizes.ItemSpacing.Y)

	-- some weird RobloxLSP bug
	if pressed == true then
		return true
	end
	return false
end

function ImGui:Indent()
	local frame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	frame.DrawCursor.PreviousPosition = frame.DrawCursor.PreviousPosition
	frame.DrawCursor.Position += Vector2.new(Style.Sizes.IndentSpacing)
end

function ImGui:Unindent()
	local frame: Types.ElementFrame = ImGui:GetActiveElementFrame()

	frame.DrawCursor.PreviousPosition = frame.DrawCursor.PreviousPosition
	frame.DrawCursor.Position -= Vector2.new(Style.Sizes.IndentSpacing)
end

function ImGui:TreeNode(text: string): (boolean)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	if (window.Collapsed == true) or (window.Open[1] == false) or (window.RedrawNextFrame == true) then
		return false
	end

	local elementFrame: Types.ElementFrame? = ImGui:GetActiveElementFrame()
	if elementFrame == nil then
		return false
	end

	if
		elementFrame.DrawCursor.Position.Y
		> math.max(elementFrame.Instance.AbsoluteSize.Y, window.Window.Frame.Instance.AbsoluteSize.Y)
	then
		return false
	end

	local treeNode = ImGui:GetElementById(elementFrame.Id .. ">" .. text, "TreeNode", elementFrame, true)
end

return ImGui
