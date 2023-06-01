local userInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Types)

local Internal = {}

local mouseX: number = 0
local mouseY: number = 0

Internal.FrameData = {
	Frame = 0,
	Time = 0,

	Windows = {},
	-- Assuming that the top window is the bottom of the list.
	WindowFocusOrder = {},

	WindowData = {
		Current = nil,
		Hovered = nil,
		-- just quickly worth noting that the ImGui windows active and nav have been
		-- collapsed into just active
		Active = nil,
		Moving = nil,
		Resizing = nil,
		Scrolling = nil,
	},

	ElementData = {
		HoverId = "",
		ActiveId = "",

		HoldOffset = Vector2.zero,
		ResizeAxis = Vector2.zero,
	},

	ScreenSize = Vector2.zero,
	GuiInset = Vector2.zero,
}

Internal.MouseData = {
	Cursor = {
		Position = Vector2.zero,
		Delta = Vector2.zero,
		Magnitude = 0,
	},

	LeftButton = {
		State = false,
		Changed = false,
		Frames = 0,
		Time = 0,
		Clicks = 0,
	},

	RightButton = {
		State = false,
		Changed = false,
		Frames = 0,
		Time = 0,
		Clicks = 0,
	},

	DoubleClickTime = 0.3,
	DoubleClickMagnitude = 6,
}

Internal.ElementData = {
	RedrawElement = false,
}

Internal.Screen = nil

function Internal:UpdateInput(deltaTime: number)
	local mouseData = Internal.MouseData

	-- we account for the guiinset and then clamp it on the screen
	local screenSize: Vector2 = Internal.Screen.AbsoluteSize
	local position: Vector2 = userInputService:GetMouseLocation() - Internal.FrameData.GuiInset
	position = Vector2.new(math.clamp(position.X, 0, screenSize.X), math.clamp(position.Y, 0, screenSize.Y))

	mouseData.Cursor.Delta = position - mouseData.Cursor.Position
	mouseData.Cursor.Position = position
	mouseData.Cursor.Magnitude = mouseData.Cursor.Delta.Magnitude -- the delta magnitude

	-- some of the mouse data is reset or updated.
	mouseData.LeftButton.Changed = false
	mouseData.LeftButton.Frames += 1
	mouseData.LeftButton.Time += deltaTime
	local leftButton: boolean = userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	mouseData.RightButton.Changed = false
	mouseData.RightButton.Frames += 1
	mouseData.RightButton.Time += deltaTime
	local rightButton: boolean = userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

	-- if the time between clicks is too long or they move too far then it doesn't count as a click
	if (Internal.FrameData.Time - mouseData.LeftButton.Time) > mouseData.DoubleClickTime or mouseData.Cursor.Magnitude > mouseData.DoubleClickMagnitude then
		mouseData.LeftButton.Clicks = 0
	end
	if (Internal.FrameData.Time - mouseData.RightButton.Time) > mouseData.DoubleClickTime or mouseData.Cursor.Magnitude > mouseData.DoubleClickMagnitude then
		mouseData.RightButton.Clicks = 0
	end

	-- change in button state - clicked if up.
	if leftButton ~= mouseData.LeftButton.State then
		mouseData.LeftButton.State = leftButton
		mouseData.LeftButton.Changed = true
		mouseData.LeftButton.Frames = 0
		mouseData.LeftButton.Time = 0
		if leftButton == false then
			mouseData.LeftButton.Clicks += 1
		end
	end
	if rightButton ~= mouseData.RightButton.State then
		mouseData.RightButton.State = rightButton
		mouseData.RightButton.Changed = true
		mouseData.RightButton.Frames = 0
		mouseData.RightButton.Time = 0
		if rightButton == false then
			mouseData.RightButton.Clicks += 1
		end
	end

	mouseX = Internal.MouseData.Cursor.Position.X
	mouseY = Internal.MouseData.Cursor.Position.Y
end

-- just a simple AABB test
function Internal:IsCursorInBox(position: Vector2, size: Vector2)
	return (mouseX >= position.X) and (mouseY >= position.Y) and (mouseX <= position.X + size.X) and (mouseY <= position.Y + size.Y)
end

function Internal:Update()
	Internal:SetHover("")
	Internal.FrameData.WindowData.Hovered = nil

	-- we just loop through all the windows and find the one the user is hovering on.
	for _, window: Types.Window in Internal.FrameData.WindowFocusOrder do
		local instance: GuiObject = window.Instance
		if Internal:IsCursorInBox(instance.AbsolutePosition, instance.AbsoluteSize) then
			Internal.FrameData.WindowData.Hovered = window
			break
		end
	end

	-- if the user is not holding down then we stop moving or resizing
	if Internal.MouseData.LeftButton.State == 0 then
		Internal.FrameData.WindowData.Moving = nil
		Internal.FrameData.WindowData.Resizing = nil
	elseif Internal.MouseData.LeftButton.Changed and Internal.FrameData.WindowData.Hovered == nil then
		-- we know the mosue has clicked down outside any windows so we clear the active
		Internal:SetActive("", nil)
	end
end

-- the hover window is updated at the start of the frame because windows movement is updated then.
function Internal:SetHover(id: Types.Id)
	Internal.FrameData.ElementData.HoverId = id
end

-- the active element remains the same even as the mouse moves so we want to update the window.
-- there is no way for us to know what the active window is each frame unless we rely on the
-- previous frame, therefore we can't wipe it at the start of the frame.
function Internal:SetActive(id: Types.Id, window: Types.Window?)
	Internal.FrameData.ElementData.ActiveId = id
	Internal.FrameData.WindowData.Active = window
end

-- this checks whether we can hover over an object
function Internal:HandleHover(position: Vector2, size: Vector2, id: Types.Id, window: Types.Window)
	local hoverId: Types.Id = Internal.FrameData.ElementData.HoverId
	local activeId: Types.Id = Internal.FrameData.ElementData.HoverId
	local windowData = Internal.FrameData.WindowData

	if (hoverId ~= "") and (hoverId ~= id) then
		return false
	end

	if (activeId ~= "") and (activeId ~= id) then
		return false
	end

	if (windowData.Hovered ~= nil) and (windowData.Hovered.Id ~= window.Id) then
		return false
	end

	if not Internal:IsCursorInBox(position, size) then
		return false
	end

	Internal:SetHover(id)
	return true
end

function Internal:HandleInteraction(position: Vector2, size: Vector2, id: Types.Id, window: Types.Window)
	local hovered: boolean = Internal:HandleHover(position, size, id, window)
	local held: boolean, pressed: boolean = false, false

	-- the hover is already set so we just check if the mouse is down
	if hovered and (Internal.MouseData.LeftButton.State == 1) then
		Internal:SetActive(id, window)
	end

	-- at the start of the frame we clear the active id unless the mouse is still down.
	if Internal.FrameData.ElementData.ActiveId == id then
		if Internal.MouseData.LeftButton.State == 1 then
			held = true
		else
			-- if the mouse is up this frame and they are still hovering then it's a click.
			pressed = hovered
		end
	end

	return hovered, held, pressed
end

return Internal
