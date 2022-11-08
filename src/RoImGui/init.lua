local guiService: GuiService = game:GetService("GuiService")
local runService: RunService = game:GetService("RunService")

local components = script.Components
local Types = require(script.Types)
local ImGuiInternal: Types.ImGuiInternal = require(script.ImGuiInternal)
local Window = require(components.Window)
local Text = require(components.Text)
local Checkbox = require(components.Checkbox)
local Style = require(script.Utility.Style)
local Utility = require(script.Utility.Utility)
local Hash = require(script.Utility.Hash)
local Flags = require(script.Flags)

local frameId: number = -1

local ImGui: Types.ImGui = {} :: Types.ImGui

ImGui.Flags = Flags

ImGui.Types = script.Types

function ImGui:DebugWindow()
	local flags: Types.WindowFlags = Flags.WindowFlags()
	flags.NoClose = true
	flags.NoCollapse = true

	ImGui:Begin("Debug", { true }, flags)
	local window: Types.ImGuiWindow = ImGui:GetWindowById("Debug")
	window.Active = true

	ImGui:Text("Elements:")
	ImGui:Indent()
	ImGui:Text("ActiveID: %s", ImGuiInternal.ActiveId or "NONE")
	ImGui:Text("HoverID: %s", ImGuiInternal.HoverId or "NONE")
	ImGui:Unindent()

	ImGui:Text("Windows:")
	ImGui:Indent()
	ImGui:Text("Active Window: %s", ImGuiInternal.ActiveWindow and ImGuiInternal.ActiveWindow.Id or "NONE")
	ImGui:Text("Hovered Window: %s", ImGuiInternal.HoveredWindow and ImGuiInternal.HoveredWindow.Id or "NONE")
	ImGui:Text("Moving Window: %s", ImGuiInternal.MovingWindow and ImGuiInternal.MovingWindow.Id or "NONE")
	ImGui:Text("Nav Window: %s", ImGuiInternal.NavWindow and ImGuiInternal.NavWindow.Id or "NONE")
	ImGui:Unindent()

	ImGui:End()
end

--[[
	Initialisation API
	
	:Start()
	:Stop()
	:Pause()
]]
function ImGui:Start()
	assert((ImGuiInternal.Status ~= "Started"), "Cannot call :Start() without stopping or pausing first.")

	ImGuiInternal.Status = "Started"

	ImGuiInternal.GuiInset = guiService:GetGuiInset()

	-- These will be called at the very start and very end of each render stepped, as long as they are connected
	-- first.

	-- These are not unbound because they are rendered first and last because they connected first to the events.
	-- A later call to :BindToRenderStep() with the same priority will be called after. Therefore to ensure this
	-- callback happens first and before any other bindings, it must be connected first and stay bound.
	runService:BindToRenderStep("ImGuiRender", Enum.RenderPriority.First.Value, function(deltaTime: number)
		if ImGuiInternal.Status == "Paused" then
			return
		end

		frameId += 1
		ImGuiInternal:UpdateTime(deltaTime)

		if ImGuiInternal.Status == "Stopped" then
			return
		end

		ImGuiInternal.HoverId = 0

		ImGuiInternal:UpdateMouseInputs(deltaTime)
		ImGui:UpdateWindowMove()
		ImGui:FindHoveredWindow()
	end)

	-- A later call to :RenderStepped() will be called before. Therefore to ensure this callback happens last and
	-- after any other bindings, it must be connected first and stay bound.
	runService.RenderStepped:Connect(function()
		if ImGuiInternal.Status ~= "Started" then
			return
		end
		ImGui:DebugWindow()

		ImGui:EndFrameMouseUpdate()

		ImGui:CleanWindowElements()
		--todo Add mouse moving window from empty space
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
		window.JustCreated = false

		if (window.WasActive == false) or (window.Open[1] == false) then
			table.remove(ImGuiInternal.WindowFocusOrder, window.FocusOrder)
			ImGuiInternal.Windows[windowIndex] = nil

			if ImGuiInternal.ActiveWindow == window then
				ImGui:SetActive(0, nil)
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

		for elementIndex: number, element: Types.ImGuiText in frame.Elements do
			if element.Active == false then
				element:Destroy()
				table.remove(frame.Elements, elementIndex)
			end

			element.Active = false
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

		if Utility.IsCursorInBox(instance.AbsolutePosition, instance.AbsoluteSize) == false then
			continue
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
	if (ImGuiInternal.ActiveId ~= 0) or (ImGuiInternal.HoverId ~= 0) then
		return
	end

	if
		((ImGuiInternal.MouseButton1.Down == true) and (ImGuiInternal.MovingWindow ~= nil))
		or (ImGuiInternal.MouseButton1.DownOnThisFrame == true)
	then
		local rootWindow: Types.ImGuiWindow? = ImGuiInternal.HoveredWindow ~= nil
				and ImGuiInternal.HoveredWindow.RootWindow
			or nil
		if rootWindow ~= nil then
			ImGui:StartWindowMove(ImGuiInternal.HoveredWindow)
		elseif (rootWindow == nil) and (ImGuiInternal.NavWindow ~= nil) then
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
function ItemHoverable(position: Vector2, size: Vector2, id: Types.ImGuiId, window: Types.ImGuiWindow)
	if ImGuiInternal.HoverId ~= 0 and ImGuiInternal.Hover ~= id then
		return false
	end

	if ImGuiInternal.HoveredWindow ~= window then
		return false
	end

	if ImGuiInternal.ActiveId ~= 0 and ImGuiInternal.ActiveId ~= id then
		return false
	end

	if Utility.IsCursorInBox(position, size) == false then
		return false
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
	window: Types.ImGuiWindow
): (boolean, boolean, boolean)
	-- Todo: create the UI ids so I can reference the current id.
	-- Todo: check whether the active and hovered are currently this button.
	-- Todo: all button checking behaviour.

	local hovered: boolean = ItemHoverable(position, size, id, window)
	local held: boolean, pressed: boolean = false, false

	if hovered == true then
		ImGuiInternal.HoverId = id
		if (ImGuiInternal.MouseButton1.DownOnThisFrame == true) and (ImGuiInternal.ActiveId ~= id) then
			ImGui:SetActive(id, window)

			ImGui:SetNavWindow(window)
			ImGui:UpdateWindowFocusOrder(window)
		end
	end

	if ImGuiInternal.ActiveId == id then
		if ImGuiInternal.MouseButton1.Down == true then
			held = true
		else
			if hovered == true then
				pressed = true
			end
			ImGui:SetActive(0, nil)
		end
	end

	return pressed, hovered, held
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

function ImGui:SetActive(id: Types.ImGuiId, window: Types.ImGuiWindow | nil)
	ImGuiInternal.ActiveId = id
	ImGuiInternal.ActiveWindow = window
end

--[[
	Manages the activity on the title bar excluding moving:
		- Checks for close and collapse buttons and updates accordingly.
		- Detects a double click on the title bar and collapses the window.
]]
function ImGui:HandleWindowTitleBar(window: Types.ImGuiWindow)
	local focusOnButton: boolean = false

	local collapse: Types.WindowTitleButton = window.Window.Title.Collapse
	if window.Flags.NoCollapse == false and collapse.Instance ~= nil then
		local instance: ImageLabel = collapse.Instance

		local pressed: boolean, hovered: boolean, held: boolean =
			ButtonBehaviour(instance.AbsolutePosition, instance.AbsoluteSize, collapse.Id, window)

		focusOnButton = pressed or hovered or held

		-- Setting the color of the buttons
		-- Prevents a double call to update colour and transparency
		if hovered == true then
			if held == true and collapse.State ~= 2 then
				instance.ImageColor3 = Style.Colours.ButtonActive.Color
				instance.ImageTransparency = Style.Colours.ButtonActive.Transparency
				collapse.State = 2

				window:UpdateTitleColour()
			elseif collapse.State ~= 1 then
				instance.ImageColor3 = Style.Colours.ButtonHovered.Color
				instance.ImageTransparency = Style.Colours.ButtonActive.Transparency
				collapse.State = 1
			end
		elseif collapse.State ~= 0 then
			instance.ImageColor3 = Style.Colours.Button.Color
			instance.ImageTransparency = 1
			collapse.State = 0
		end

		if pressed == true then
			window.Collapsed = not window.Collapsed
			window.RedrawNextFrame = true
		end
	end

	local close: Types.WindowTitleButton = window.Window.Title.Close
	if window.Flags.NoClose == false and close.Instance ~= nil then
		local instance: ImageLabel = close.Instance

		local pressed: boolean, hovered: boolean, held: boolean =
			ButtonBehaviour(instance.AbsolutePosition, instance.AbsoluteSize, close.Id, window)

		focusOnButton = pressed or hovered or held

		if hovered == true then
			if held == true and close.State ~= 2 then
				instance.ImageColor3 = Style.Colours.ButtonActive.Color
				instance.ImageTransparency = Style.Colours.ButtonActive.Transparency
				close.State = 2

				window:UpdateTitleColour()
			elseif close.State ~= 1 then
				instance.ImageColor3 = Style.Colours.ButtonHovered.Color
				instance.ImageTransparency = Style.Colours.ButtonActive.Transparency
				close.State = 1
			end
		elseif close.State ~= 0 then
			instance.ImageColor3 = Style.Colours.Button.Color
			instance.ImageTransparency = 1
			close.State = 0
		end

		if pressed == true then
			window.Open[1] = false
			window.RedrawNextFrame = true
		end
	end

	local title: Types.WindowTitle = window.Window.Title
	if (focusOnButton == false) and (title.Instance ~= nil) then
		local instance: Frame = title.Instance

		local hovered: boolean = ItemHoverable(instance.AbsolutePosition, instance.AbsoluteSize, title.Id, window)

		if (hovered == true) and (ImGuiInternal.MouseButton1.ClicksThisFrame == 2) then
			window.Collapsed = not window.Collapsed
			window.RedrawNextFrame = true
			-- Have to draw it next frame because we have already done so this frame.
			-- Unlike Dear ImGui, we are relying on the absolute properties, so we can't detect a click before drawing for the frame.
		end
	end
end

function ImGui:StartWindowMove(window: Types.ImGuiWindow)
	ImGui:SetNavWindow(window)
	ImGui:UpdateWindowFocusOrder(window)

	ImGuiInternal.MovingWindow = window
end

function ImGui:UpdateWindowMove()
	local window: Types.ImGuiWindow? = ImGuiInternal.MovingWindow

	if window == nil then
		return
	end

	if ImGuiInternal.MouseButton1.Down == true then
		window.Position += ImGuiInternal.MouseCursor.Delta
		window:UpdatePosition()
		ImGui:UpdateWindowFocusOrder(window)
		ImGui:SetActive(0, nil)
	else
		ImGuiInternal.MovingWindow = nil
		ImGui:SetActive(0, nil)
	end
end

--[[
	CREATION FUNCTIONS

	Window functions

	:Begin()
	:End()
]]
function ImGui:Begin(windowName: string, open: { boolean }?, flags: Types.WindowFlags | nil)
	-- just create a set of default flags
	flags = flags or Flags.WindowFlags()

	-- if the window is not open at all (based on previous window data)
	if (open ~= nil) and (open[1] == false) and (flags.NoClose == false) then
		return false
	end

	local previousWindow: Types.ImGuiWindow? = ImGui:GetWindowById(windowName)
	local window: Types.ImGuiWindow = previousWindow or ImGui:CreateWindow(windowName, flags)

	local firstFrameCall: boolean = (window.LastFrameActive ~= frameId) -- If this is the first time in the renderstep for creating the window
	local windowApearing: boolean = (window.LastFrameActive < (frameId - 1))

	if flags.Popup == true then
		windowApearing = true -- OpenPopupStack required to check
	end

	window.Appearing = windowApearing

	if firstFrameCall == true then
		window.Flags = flags
		window.LastFrameActive = frameId
	end

	local parentWindowFromStack: Types.ImGuiWindow = ImGuiInternal.WindowStack[#ImGuiInternal.WindowStack] -- the last used window in the stack
	local parentWindow: Types.ImGuiWindow? = firstFrameCall and parentWindowFromStack or window.ParentWindow -- either the stack window or the window's parent

	table.insert(ImGuiInternal.WindowStack, window)
	ImGuiInternal.CurrentWindow = window
	table.insert(ImGuiInternal.ElementFrameStack, window.Window.Frame) -- append the window frame to the elementframe stack. Sets the next draw position to the window frame.

	if flags.ChildWindow == true then
		ImGuiInternal.ChildWindowCount += 1
	end

	if flags.Popup == true then
		print("Popup window created!")
	end

	-- don't know why exactly?
	if ((window.Open[1] == false) and (flags.NoClose == false)) or (flags.Collapsed == true) then
		window.Collapsed = true
	end

	if firstFrameCall == true then
		local tooltip: boolean = (flags.ChildWindow == true) and (flags.Tooltip == true)

		ImGui:UpdateWindowLinks(window, flags, parentWindow)
		window.ParentWindowFromStack = parentWindowFromStack
		window.Active = true
		window.Open = open or { true }
		window:DrawWindow()

		if (flags.NoTitleBar == false) and (flags.NoCollapse == false) then
			tooltip = tooltip
		end

		if windowApearing == true then
			if (flags.Popup == true) and (flags.Modal == false) then
				window.Position = window.Position
			end
		end

		if flags.ChildWindow == true then
			table.insert(parentWindow.ChildWindows, window)
		end

		if flags.NoTitleBar == false then
			window:DrawTitle()
			ImGui:HandleWindowTitleBar(window)
		end

		window:DrawFrame()
	end

	window.LastFrameActive = frameId

	ImGuiInternal.ActiveWindow = window

	-- A lot of internal code in here!f

	local skipWindow: boolean = (window.Collapsed == true) or (window.Active == false) or (window.Open[1] == false)

	return not skipWindow
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
function ImGui:GetElementById(id: Types.ImGuiId, class: string, elementFrame: Types.ElementFrame): (Types.Element?)
	local element: Types.Element

	for _, childElement: Types.ImGuiText in elementFrame.Elements do
		if (childElement.Id == id) and (childElement.Class == class) then
			element = childElement
			break
		end
	end

	return element
end

function ImGui:Text(textString: string, ...)
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- We don't draw if it is going to be redrawn next frame.
	-- Don't remove because the text is parented to an instance and when it redraws next frame
	-- the instance is destroyed so the text only appears for a frame and is then destroyed
	-- so we don't draw at all.
	-- Settings the text to redraw next frame would already happen, so why render at all.
	if (window.Collapsed == true) or (window.RedrawNextFrame == true) then
		return
	end

	local elementFrame: Types.ElementFrame? = ImGui:GetActiveElementFrame()
	if elementFrame == nil then
		return
	end

	-- format with the args
	local args: { any } = { ... }
	if #args > 0 then
		textString = textString:format(...)
	end

	local text: Types.ImGuiText? = ImGui:GetElementById(elementFrame.Id .. ">" .. textString, "Text", elementFrame)

	if text == nil then
		text = Text.new(textString, window, elementFrame)
		text:DrawText(elementFrame.DrawCursor.Position)
		table.insert(elementFrame.Elements, text)
	else
		text:UpdatePosition(elementFrame.DrawCursor.Position)
	end

	text.Active = true

	elementFrame.DrawCursor.PreviousPosition = elementFrame.DrawCursor.Position
	elementFrame.DrawCursor.Position += Vector2.new(0, text.Size.Y + Style.Sizes.ItemSpacing.Y)
end

function ImGui:Checkbox(text: string, value: { boolean })
	local window: Types.ImGuiWindow = ImGuiInternal.CurrentWindow

	-- see ImGui:Text()
	if (window.Collapsed == true) or (window.RedrawNextFrame == true) then
		return
	end

	local elementFrame: Types.ElementFrame? = ImGui:GetActiveElementFrame()
	if elementFrame == nil then
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

	elementFrame.DrawCursor.PreviousPosition = elementFrame.DrawCursor.PreviousPosition
	elementFrame.DrawCursor.Position += Vector2.new(0, checkbox.Size.Y + Style.Sizes.ItemSpacing.Y)
end

function ImGui:Indent()
	local elementFrameStackLength: number = #ImGuiInternal.ElementFrameStack
	if (ImGuiInternal.CurrentWindow == nil) or (elementFrameStackLength == 0) then
		return
	end

	local frame: Types.ElementFrame = ImGuiInternal.ElementFrameStack[elementFrameStackLength]

	frame.DrawCursor.PreviousPosition = frame.DrawCursor.PreviousPosition
	frame.DrawCursor.Position += Vector2.new(Style.Sizes.IndentSpacing)
end

function ImGui:Unindent()
	local elementFrameStackLength: number = #ImGuiInternal.ElementFrameStack
	if (ImGuiInternal.CurrentWindow == nil) or (elementFrameStackLength == 0) then
		return
	end

	local frame: Types.ElementFrame = ImGuiInternal.ElementFrameStack[elementFrameStackLength]

	frame.DrawCursor.PreviousPosition = frame.DrawCursor.PreviousPosition
	frame.DrawCursor.Position -= Vector2.new(Style.Sizes.IndentSpacing)
end

return ImGui
