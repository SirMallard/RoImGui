local guiService: GuiService = game:GetService("GuiService")
local runService: RunService = game:GetService("RunService")

local components = script.Components
local Types = require(script.Types)
local ImGuiInternal: Types.ImGuiInternal = require(script.ImGuiInternal)
local Window = require(components.Window)
local Style = require(script.Utility.Style)
local Utility = require(script.Utility.Utility)
local Flags = require(script.Flags)

local frameId: number = -1

local ImGui = {}

local function FindHoveredWindow()
	ImGuiInternal.HoveredWindow = nil

	for _, window: Types.ImGuiWindow in ImGuiInternal.Windows do
		if (window.WasActive == false) or (window.Open[1] == false) then
			continue
		end

		if Utility.IsCursorInBox(window.Position, window.Size) == false then
			continue
		end

		ImGuiInternal.HoveredWindow = window

		break
	end
end

--[[
	Functions to be called before or after code.

	Generally for cleaning and updating last frame data.
]]
-- Iterates through all the windows, changing their active properties and
local function ClearWindow()
	for index: string, window: Types.ImGuiWindow in ImGuiInternal.Windows do
		window.WasActive = window.Active
		window.Active = false
		window.JustCreated = false

		if window.WasActive == false then
			window:Destroy()
			ImGuiInternal.Windows[index] = nil
		end
	end
end

local function CleanWindowElements()
	for _, window: Types.ImGuiWindow in ImGuiInternal.Windows do
		-- loop through all menubars

		window.RedrawThisFrame = window.RedrawNextFrame
		window.RedrawNextFrame = false

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
	end
end

local function UpdateWindowFocusOrder(window: Types.ImGuiWindow?)
	if window ~= nil then
		local index: number = table.find(ImGuiInternal.WindowFocusOrder, window)
		table.remove(ImGuiInternal.WindowFocusOrder, index)
		table.insert(ImGuiInternal.WindowFocusOrder, window)
	end

	for order: number, focusWindow: Types.ImGuiWindow in ImGuiInternal.WindowFocusOrder do
		if focusWindow.Window.Instance ~= nil then
			focusWindow.Window.Instance.ZIndex = order
			focusWindow.FocusOrder = order
		end
	end
end

function UpdateWindowInFocusOrderList(window: Types.ImGuiWindow, new_window: boolean)
	if new_window == true then
		table.insert(ImGuiInternal.WindowFocusOrder, window)
		window.FocusOrder = #ImGuiInternal.WindowFocusOrder - 1
	end
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

		ImGuiInternal.Frame += 1
		frameId += 1
		ImGuiInternal.ElapsedTime += deltaTime

		if ImGuiInternal.Status == "Stopped" then
			return
		end

		ImGuiInternal.HoverId = 0

		ImGuiInternal:UpdateMouseInputs()
		FindHoveredWindow()
		CleanWindowElements()
	end)

	-- A later call to :RenderStepped() will be called before. Therefore to ensure this callback happens last and
	-- after any other bindings, it must be connected first and stay bound.
	runService.RenderStepped:Connect(function()
		if ImGuiInternal.Status ~= "Started" then
			return
		end

		ClearWindow()
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

	ImGuiInternal.HoverId = id

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
		if (ImGuiInternal.MouseButton1.DownOnThisFrame == true) and (ImGuiInternal.ActiveId ~= id) then
			ImGuiInternal.ActiveId = id
			ImGuiInternal.ActiveWindow = window

			UpdateWindowFocusOrder(window)
		end
	end

	if ImGuiInternal.ActiveId == id then
		if ImGuiInternal.MouseButton1.Down == true then
			held = true
		else
			if hovered == true then
				pressed = true
			end
			ImGuiInternal.ActiveId = 0
		end
	end

	return pressed, hovered, held
end

-- Updates RootWindow properties of the current window based upon flags
function UpdateWindowLinks(window: Types.ImGuiWindow, flags: Types.WindowFlags, parentWindow: Types.ImGuiWindow?)
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

function ImGui:AdvanceDrawCursor(size: Vector2, yOffset: number?, xOffset: number?)
	ImGuiInternal.DrawPosition.Y += size.Y + (yOffset or 0)
	ImGuiInternal.DrawPosition.X += (xOffset or 0)
end

function ImGui:GetWindowByName(windowName: string): (Types.ImGuiWindow?)
	return ImGuiInternal.Windows[windowName] or nil
end

function ImGui:CreateWindow(windowName: string, flags: Types.WindowFlags): (Types.ImGuiWindow)
	local parentWindow: Types.ImGuiWindow? = nil

	local window: Types.ImGuiWindow = Window.new(windowName, parentWindow, flags)

	ImGuiInternal.Windows[windowName] = window
	table.insert(ImGuiInternal.WindowOrder, window)

	return window
end

function ImGui:HandleWindowTitleBar(window: Types.ImGuiWindow)
	if window.Flags.NoCollapse == false and window.Window.Title.Collapse.Instance ~= nil then
		local collapse: Types.WindowTitleButton = window.Window.Title.Collapse
		local instance: ImageLabel = collapse.Instance
		local position: Vector2 = instance.AbsolutePosition
		local size: Vector2 = instance.AbsoluteSize

		local pressed: boolean, hovered: boolean, held: boolean =
			ButtonBehaviour(position, size, window.Window.Title.Collapse.Id, window)

		-- Setting the color of the buttons
		-- Prevents a double call to update colour and transparency
		if hovered == true then
			if held == true and collapse.State ~= 2 then
				instance.ImageColor3 = Style.Colours.ButtonActive.Color
				instance.ImageTransparency = Style.Colours.ButtonActive.Transparency
				collapse.State = 2
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

	if window.Flags.NoClose == false and window.Window.Title.Close.Instance ~= nil then
		local close: Types.WindowTitleButton = window.Window.Title.Close
		local instance: ImageLabel = close.Instance
		local position: Vector2 = instance.AbsolutePosition
		local size: Vector2 = instance.AbsoluteSize

		local pressed: boolean, hovered: boolean, held: boolean =
			ButtonBehaviour(position, size, window.Window.Title.Close.Id, window)

		if hovered == true then
			if held == true and close.State ~= 2 then
				instance.ImageColor3 = Style.Colours.ButtonActive.Color
				instance.ImageTransparency = Style.Colours.ButtonActive.Transparency
				close.State = 2
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
end

--[[
	Window functions

	:Begin()
	:End()
]]
function ImGui:Begin(
	windowName: string,
	open: { boolean }?,
	flags: Types.WindowFlags?,
	optional_arugments: { [string]: any }?
)
	if flags == nil then
		-- just create a set of default flags
		flags = Flags.WindowFlags.new() :: Types.WindowFlags
	end

	local previousWindow: Types.ImGuiWindow? = ImGui:GetWindowByName(windowName)
	local new_window: boolean = (previousWindow == nil)
	local window: Types.ImGuiWindow = previousWindow or ImGui:CreateWindow(windowName, flags)

	if optional_arugments ~= nil then
		for argument: string, value: any in optional_arugments do
			window[argument] = value
		end
	end

	UpdateWindowInFocusOrderList(window, new_window)

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

	local parentWindowFromStack: Types.ImGuiWindow? = ImGuiInternal.WindowStack[#ImGuiInternal.WindowStack] -- the last used window in the stack
	local parentWindow: Types.ImGuiWindow? = firstFrameCall and parentWindowFromStack or window.ParentWindow -- either the stack window or the window's parent

	table.insert(ImGuiInternal.WindowStack, window)

	if flags.ChildWindow == true then
		ImGuiInternal.ChildWindowCount += 1
	end

	if flags.Popup == true then
		print("Popup window created!")
	end

	window.Open = open or { true }
	if ((window.Open[1] == false) and (flags.NoClose == false)) or (flags.Collapsed == true) then
		window.CollapsedThisFrame = window.Collapsed == false
		window.Collapsed = true
	end

	ImGuiInternal.CurrentWindow = window
	if firstFrameCall == true then
		local tooltip: boolean = (flags.ChildWindow == true) and (flags.Tooltip == true)

		UpdateWindowLinks(window, flags, parentWindow)
		window.ParentWindowFromStack = parentWindowFromStack
		window.Active = true
		flags.NoClose = open == nil
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
	end

	window.LastFrameActive = frameId

	ImGuiInternal.ActiveWindow = window

	-- A lot of internal code in here!f

	local skipWindow: boolean = (not window.Collapsed or not window.Active or not window.Open[0])

	return skipWindow
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
end

return ImGui
