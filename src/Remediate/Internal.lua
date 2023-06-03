--[[
	Frames:
		- we don't change windows values initially unless they are in response to the user.
		  ie. mouse moved to resize
		Start:
			Refresh - we want to remove all elements at the start ideally.

			Mouse - the new mouse inputs and positions are fetched.
			Hover - cleared
			Hovered window - cleared and the hovered window is found and set.
			Active window - possibly cleared and the hovered window and button down makes it active.
			Moved windows -  possibly cleared and the positions are updated to reflect the mouse position.
			Resized windows - same as above.

		User:
			Hover - the hovering element.
			Active - possibily cleared and the mouse button down element.
			Active window - edge case for literally the edges of windows which overalap
				the size but still count as active - resize elements extend

		End:
			Focsus order - the user has clicked on a window and not clicked an element.
			Window move - no element is selected so we allow the window to move.
			
]]

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
	WindowStack = {},

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

-- just a simple AABB test.
function Internal:IsCursorInBox(position: Vector2, size: Vector2)
	return (mouseX >= position.X) and (mouseY >= position.Y) and (mouseX <= position.X + size.X) and (mouseY <= position.Y + size.Y)
end

function Internal:PreFrameUpdate()
	local frameData = Internal.FrameData
	Internal:SetHover("")
	frameData.WindowData.Hovered = nil

	-- we just loop through all the windows and find the one the user is hovering on.
	for index = #frameData.WindowFocusOrder, 1, -1 do
		local window: Types.Window = frameData.WindowFocusOrder[index]
		local instance: GuiObject = window.Instance
		if Internal:IsCursorInBox(instance.AbsolutePosition, instance.AbsoluteSize) then
			frameData.WindowData.Hovered = window
			break
		end
	end

	-- if the user is not holding down then we stop moving or resizing.
	if Internal.MouseData.LeftButton.State == false then
		frameData.WindowData.Moving = nil
		frameData.WindowData.Resizing = nil
	elseif Internal.MouseData.LeftButton.Changed then
		if frameData.WindowData.Hovered == nil then
			-- we know the mosue has clicked down outside any windows so we clear the active window.
			frameData.WindowData.Active = nil
		else
			-- a click in a window so set that window as active.
			frameData.WindowData.Active = frameData.WindowData.Hovered
		end
	end

	Internal:UpdateWindows()
end

function Internal:PostFrameUpdate()
	local frameData = Internal.FrameData
	for zindex: number, window: Types.Window in frameData.WindowFocusOrder do
		-- the first element is at the bottom.
		window.Instance.ZIndex = zindex
	end

	-- if the mouse is down and there is not active elemnts then the mouse is on the frame so we just
	if (Internal.MouseData.LeftButton.State == true) and (frameData.ElementData.HoverId == "") and (frameData.ElementData.ActiveId == "") then
		local window: Types.Window = frameData.WindowData.Active
		frameData.WindowData.Moving = window
		frameData.ElementData.HoldOffset = Internal.MouseData.Cursor.Position - window.Properties.Position
	end
end

function Internal:UpdateWindows()
	local frameData = Internal.FrameData
	local window: Types.Window? = frameData.WindowData.Moving

	if window ~= nil then
		-- if the window is down then we move the window relative to the offset and the mouse.
		if Internal.MouseData.LeftButton.State == true then
			window.Properties.Position = Internal.MouseData.Cursor.Position - frameData.ElementData.HoldOffset
		else
			frameData.WindowData.Moving = nil
			frameData.ElementData.HoldOffset = Vector2.zero
		end
		-- clearly they are acting on the window and not an element
		Internal:SetActive("")
	end

	window = frameData.WindowData.Resizing

	if window ~= nil then
		if Internal.MouseData.LeftButton.State == true then
			local position: Vector2 = window.Properties.Position
			local size: Vector2 = window.Properties.Size
			local minimumSize: Vector2 = window.Properties.MinimumSize
			local offset: Vector2 = frameData.ElementData.HoldOffset
			local resizeSize: Vector2 = frameData.ElementData.ResizeAxis
			local screenSize: Vector2 = frameData.ScreenSize
			local newPosition: Vector2 = position
			local newSize: Vector2 = size

			local mousePosition: Vector2 = Internal.MouseData.Cursor.Position

			-- DON'T TOUCH THIS CODE.
			-- this maths took a lot of trial an error. I'm not going to explain it specifically.
			-- the position and size may change and is clamped onto the screen.
			if resizeSize.X > 0 then
				newSize = Vector2.new(math.clamp(mousePosition.X - position.X - offset.X, minimumSize.X, screenSize.X - position.X), newSize.Y)
			elseif resizeSize.X < 0 then
				newSize = Vector2.new(math.clamp(position.X + size.X - mousePosition.X + offset.X, minimumSize.X, screenSize.X - position.X - minimumSize.X), newSize.Y)
				newPosition = Vector2.new(math.clamp(mousePosition.X - offset.X, 0, position.X + size.X - minimumSize.X), newPosition.Y)
			end

			if resizeSize.Y > 0 then
				newSize = Vector2.new(newSize.X, math.clamp(mousePosition.Y - position.Y - offset.Y, minimumSize.Y, screenSize.Y - position.Y))
			elseif resizeSize.Y < 0 then
				newSize = Vector2.new(newSize.X, math.clamp(position.Y + size.Y - mousePosition.Y + offset.Y, minimumSize.Y, screenSize.Y - position.Y - minimumSize.Y))
				newPosition = Vector2.new(newPosition.X, math.clamp(mousePosition.Y - offset.Y, -offset.Y, position.Y + size.Y - minimumSize.Y))
			end

			window.Properties.Position = newPosition
			window.Properties.Size = newSize
		else
			frameData.WindowData.Resizing = nil
			frameData.ElementData.HoldOffset = Vector2.zero
			frameData.ElementData.ResizeAxis = Vector2.zero
		end

		Internal:SetActive("")
	end
end

function Internal:RefreshElements()
	-- the frame has incremented already so we have to backtrack to the last frame it should be at.
	local validFrame: number = Internal.FrameData.Frame - 1
	local frameData = Internal.FrameData
	for _, window: Types.Window in frameData.Windows do
		if window.Frame < validFrame then
			table.remove(frameData.WindowFocusOrder, table.find(frameData.WindowFocusOrder, window))
			frameData.Windows[window.Id] = nil

			if window == frameData.WindowData.Active then
				frameData.WindowData.Active = nil
			end
			if frameData.WindowData.Moving == window then
				frameData.WindowData.Moving = nil
			end
			if frameData.WindowData.Resizing == window then
				frameData.WindowData.Resizing = nil
			end

			-- we also want to clear everything else in the window.
			-- either we just destroy the window and allow a garbage cleanup or explicitly go
			-- through each element. The instances should all be garbage collected eventually.
			window:Destroy()
		end

		-- we just loop through all the elements and we destroy the ones that should no longer be there.
		for id: Types.Id, element: Types.Element in window.Elements do
			if element.Frame < validFrame then
				element:Destroy()
				window.Elements[id] = nil
			end
		end

		-- we reset the draw cursor again.
		window.DrawCursor = {
			Position = Vector2.zero,
			PreviousPosition = Vector2.zero,
			MaximumPosition = Vector2.zero,
			LineHeight = 0,
			TextLineOffset = 0,
			Indent = 0,
			SameLine = false,
		}
	end
end

-- the hover window is updated at the start of the frame because windows movement is updated then.
function Internal:SetHover(id: Types.Id)
	Internal.FrameData.ElementData.HoverId = id
end

-- the active element remains the same even as the mouse moves so we want to update the window.
-- there is no way for us to know what the active window is each frame unless we rely on the
-- previous frame, therefore we can't wipe it at the start of the frame.
function Internal:SetActive(id: Types.Id)
	Internal.FrameData.ElementData.ActiveId = id
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

	-- the hover is already set so we just check if the mouse is down.
	if hovered and (Internal.MouseData.LeftButton.State == true) then
		Internal:SetActive(id)
		Internal.FrameData.WindowData.Active = window
	end

	-- at the start of the frame we clear the active id unless the mouse is still down.
	if Internal.FrameData.ElementData.ActiveId == id then
		if Internal.MouseData.LeftButton.State == true then
			held = true
		else
			-- if the mouse is up this frame and they are still hovering then it's a click.
			-- however, the mosue is no longer down so the element is not active.
			pressed = hovered
			Internal:SetActive("")
		end
	end

	return hovered, held, pressed
end

return Internal
