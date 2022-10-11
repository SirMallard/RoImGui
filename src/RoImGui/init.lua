local userInputService: UserInputService = game:GetService("UserInputService")
local runService: RunService = game:GetService("RunService")

local components = script.Components
local Types = require(script.Types)
local ImGuiInternal: Types.ImGuiInternal = require(script.ImGuiInternal)
local Window = require(components.Window)
local Style = require(script.Utility.Style)
local Utility = require(script.Utility.Utility)

local frameId: number = -1

local ImGui = {}

function FindHoveredWindow()
	for _, window: Types.ImGuiWindow in ImGuiInternal.Windows do
		if (window.Active == false) or (window.Open[1] == false) then
			continue
		end

		if Utility.IsCursorInBox(window.Postion, window.Size) == false then
			continue
		end

		ImGuiInternal.HoveredWindow = window
		break
	end
end

local function UpdateMouseInputs()
	ImGuiInternal.MouseButton1.DownOnThisFrame = false
	ImGuiInternal.MouseButton1.UpOnThisFrame = false
	-- Set up the data for the frame.
	ImGuiInternal.MouseCursor.MousePosition = userInputService:GetMouseLocation()
	ImGuiInternal.MouseCursor.MouseDelta = userInputService:GetMouseDelta()
	Utility.Update(ImGuiInternal.MouseCursor.MousePosition)

	local mouse1Down: boolean = userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	if mouse1Down == true then
		ImGuiInternal.MouseButton1.DownFrames += 1 -- Down for at least 1 frame.
		if ImGuiInternal.MouseButton1.Down == false then
			ImGuiInternal.MouseButton1.DownOnThisFrame = true -- Not already marked as down, so must be first time.
		end
	elseif mouse1Down == false then
		if ImGuiInternal.MouseButton1.Up == false then
			ImGuiInternal.MouseButton1.UpOnThisFrame = true -- Not already marked as up, so must be first time.
			ImGuiInternal.MouseButton1.DownFrames = 0 -- No need to write every frame.
		end
	end

	ImGuiInternal.MouseButton1.Down = mouse1Down
	ImGuiInternal.MouseButton1.Up = not mouse1Down

	local mouse2Down: boolean = userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	if mouse2Down == true then
		ImGuiInternal.MouseButton2.DownFrames += 1 -- Down for at least 1 frame.
		if ImGuiInternal.MouseButton2.Down == false then
			ImGuiInternal.MouseButton2.DownOnThisFrame = true -- Not already marked as down, so must be first time.
		end
	elseif mouse2Down == false then
		if ImGuiInternal.MouseButton2.Up == false then
			ImGuiInternal.MouseButton2.UpOnThisFrame = true -- Not already marked as up, so must be first time.
			ImGuiInternal.MouseButton2.DownFrames = 0 -- No need to write every frame.
		end
	end

	ImGuiInternal.MouseButton2.Down = mouse2Down
	ImGuiInternal.MouseButton2.Up = not mouse2Down
end

-- Iterates through all the windows, changing their active properties and
local function ClearWindow()
	for _, window: Types.ImGuiWindow in ImGuiInternal.Windows do
		window.WasActive = window.Active
		window.Active = false
		window.JustCreated = false

		if window.WasActive == false then
			window:Destroy()
		end
	end
end

function ImGui:Start()
	assert((ImGuiInternal.Status == "Started"), "Cannot call :Start() without stopping or pausing first.")

	ImGuiInternal.Status = "Started"

	-- These will be called at the very start and very end of each render stepped, as long as they are connected
	-- first.

	-- These are not unbound because they are rendered first and last because they connected first to the events.
	-- A later call to :BindToRenderStep() with the same priority will be called after. Therefore to ensure this
	-- callback happens first and before any other bindings, it must be connected first and stay bound.
	runService:BindToRenderStep("ImGuiRender", Enum.RenderPriority.First.Value, function(deltaTime: number)
		if ImGuiInternal.Status == "Paused" then
			return
		end

		ImGuiInternal.FrameId += 1
		frameId += 1
		ImGuiInternal.ElapsedTime += deltaTime

		if ImGuiInternal.Status == "Stopped" then
			return
		end

		ImGuiInternal.HoverId = nil
		ImGuiInternal.Hover = nil

		UpdateMouseInputs()

		FindHoveredWindow()
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

-- Used to determine the final size of the object.
-- Todo: mark offset from window to clamp.
function CalculateItemSize(size: Vector2, defaultWidth: number, defaultHeight: number): (Vector2)
	if size.X == 0 then
		size.X = defaultWidth
	end

	if size.Y == 0 then
		size.Y = defaultHeight
	end

	return size
end

function ButtonBehaviour(position: Vector2, size: Vector2): (boolean, boolean, boolean)
	-- Todo: create the UI ids so I can reference the current id.
	-- Todo: check whether the active and hovered are currently this button.
	-- Todo: all button checking behaviour.
	Utility.IsCursorInBox(position, size)

	return true, true, true
end

function UpdateWindowInFocusOrderList(window: Types.ImGuiWindow, new_window: boolean, flags: any?)
	if new_window == true then
		table.insert(ImGuiInternal.WindowFocusOrder, window)
		window.FocusOrder = #ImGuiInternal.WindowFocusOrder - 1
	end

	flags = flags
end

function ImGui:AdvanceDrawCursor(size: Vector2, yOffset: number?, xOffset: number?)
	ImGuiInternal.DrawPosition.Y += size.Y + (yOffset or 0)
	ImGuiInternal.DrawPosition.X += (xOffset or 0)
end

function ImGui:GetWindowByName(windowName: string): (Types.ImGuiWindow?)
	return ImGuiInternal.Windows[windowName] or nil
end

function ImGui:CreateWindow(windowName: string, flags: any?): (Types.ImGuiWindow)
	local parentWindow: Types.ImGuiWindow? = nil

	local window: Types.ImGuiWindow = Window.new(windowName, parentWindow, flags)

	ImGuiInternal.Windows[windowName] = window
	table.insert(ImGuiInternal.WindowOrder, window)

	return window
end

function ImGui:Begin(windowName: string, open: { boolean }?, flags: any?)
	local previousWindow: Types.ImGuiWindow? = ImGui:GetWindowByName(windowName)
	local new_window: boolean = (previousWindow == nil)
	local window: Types.ImGuiWindow = previousWindow or ImGui:CreateWindow(windowName, flags)

	UpdateWindowInFocusOrderList(window, new_window, flags)

	local firstFrameCall: boolean = (window.LastFrameActive ~= frameId) -- If this is the first time in the renderstep for creating the window

	if firstFrameCall == true then
		window.LastFrameActive = frameId
	end

	local parentWindowFromStack: Types.ImGuiWindow? = ImGuiInternal.WindowStack[#ImGuiInternal.WindowStack]
	local parentWindow: Types.ImGuiWindow? = firstFrameCall and parentWindowFromStack or window.ParentWindow

	parentWindow = parentWindow

	window.Open = open or { true }
	window.Closed = open and { not open[0] } or { false }

	window.LastFrameActive = frameId

	ImGuiInternal.ActiveWindow = window

	-- A lot of internal code in here!

	local skipWindow: boolean = (not window.Collapsed or not window.Active or window.Closed[0])

	return skipWindow
end

function ImGui:End()
	assert(
		(ImGuiInternal.Active ~= nil) and (ImGuiInternal.Active.TYPE == "WIDGET"),
		"Cannot call :End()\n\tYou are currently in a " .. ImGuiInternal.Active
			and ImGuiInternal.Active.TYPE .. " element."
	)

	ImGuiInternal.Active = nil
end

function ImGui:BeginMenuBar()
	assert(
		(ImGuiInternal.Active ~= nil) and (ImGuiInternal.Active.TYPE == "WIDGET"),
		"Cannot call :BeginMenuBar()\n\tYou are currently in a " .. ImGuiInternal.Active
			and ImGuiInternal.Active.TYPE .. " element."
	)

	if ImGuiInternal.Active.flags.NoMenu == false then
		return false
	end

	local menubar = ImGuiInternal.Active.MenuBar or {
		TYPE = "MENUBAR",
		parent = ImGuiInternal.Active,
	}

	menubar.flags = ImGuiInternal.Active.flags

	ImGuiInternal.Active = menubar

	return true
end

function ImGui:EndMenuBar()
	assert(
		(ImGuiInternal.Active ~= nil) and (ImGuiInternal.Active.TYPE == "MENUBAR"),
		"Cannot call :EndMenuBar()\n\tYou are currently in a " .. ImGuiInternal.Active
			and ImGuiInternal.Active.TYPE .. " element."
	)

	ImGuiInternal.Active = ImGuiInternal.Active.Parent
end

function ImGui:BeginMenu(menuName: string)
	assert(
		(ImGuiInternal.Active ~= nil) and (ImGuiInternal.Active.Type == "MENUBAR"),
		"Cannot call :BeginMenu()\n\tYou are current in a " .. ImGuiInternal.Active
			and ImGuiInternal.Active.TYPE .. " element."
	)

	local menu = ImGuiInternal.Active.Menu[menuName] or {
		TYPE = "MENU",
		parent = ImGuiInternal.Active,
	}

	menu.flags = ImGuiInternal.Active.flags
	menu.children = nil
end

function ImGui:Button(buttonText: string, forcedSize: Vector2?)
	local position: Vector2 = ImGuiInternal.DrawPosition
	local textSize: Vector2 = Utility.CalculateTextSize(buttonText)
	local size: Vector2 = CalculateItemSize(
		forcedSize or Vector2.zero,
		textSize.X + (2 * Style.Sizes.FramePadding.X),
		textSize.Y + (2 * Style.Sizes.FramePadding.Y)
	)

	ImGui:AdvanceDrawCursor(size, Style.Sizes.ItemSpacing.Y)

	local pressed: boolean, hovered: boolean, held: boolean = ButtonBehaviour(position, size)

	pressed = pressed
	hovered = hovered
	held = held

	return true
end

return ImGui
