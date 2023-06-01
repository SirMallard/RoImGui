local guiService = game:GetService("GuiService")
local runService: RunService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local Types = require(script.Types)
local Style = require(script.Utility.Style)
local Internal = require(script.Internal)

local Remediate = {} :: Types.Remediate
Remediate.Status = 0

function Remediate:Start()
	if Remediate.Status == 1 then
		return
	end

	runService:BindToRenderStep("RemediateRender", Enum.RenderPriority.First.Value, Remediate.Update)
end

function Remediate:Stop()
	if Remediate.Status == 0 then
		return
	end

	runService:UnbindFromRenderStep("RemediateRender")
end

function Remediate:Initialise()
	local screen: ScreenGui = Instance.new("ScreenGui")
	screen.Name = "Remediate"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.IgnoreGuiInset = false
	screen.DisplayOrder = 100

	Internal.Screen = screen

	Internal.FrameData.GuiInset = guiService:GetGuiInset()
end

function Remediate.Update(deltaTime: number)
	local frameData = Internal.FrameData

	frameData.Frame += 1
	frameData.Time += deltaTime

	Remediate:UpdateInput(deltaTime)
end

function Remediate:UpdateInput(deltaTime: number)
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
	if
		(Internal.FrameData.Time - mouseData.LeftButton.Time) > mouseData.DoubleClickTime
		or mouseData.Cursor.Magnitude > mouseData.DoubleClickMagnitude
	then
		mouseData.LeftButton.Clicks = 0
	end
	if
		(Internal.FrameData.Time - mouseData.RightButton.Time) > mouseData.DoubleClickTime
		or mouseData.Cursor.Magnitude > mouseData.DoubleClickMagnitude
	then
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
end

function Remediate:_getId()
	local index: number = 1
	local level: number = debug.info(index, "l")
	local id: string = ""
	while level ~= -1 and level ~= nil do
		id ..= "+" .. level
		index += 1
		level = debug.info(index, "l")
	end

	local hash: number = 0
	for _, s: string in id:split("") do
		hash += s:byte()
		hash = bit32.band(hash, 0xffffffff)
		hash += bit32.lshift(hash, 10)
		hash = bit32.band(hash, 0xffffffff)
		hash = bit32.bxor(hash, bit32.rshift(hash, 6))
		hash = bit32.band(hash, 0xffffffff)
	end
	hash += bit32.lshift(hash, 3)
	hash = bit32.band(hash, 0xffffffff)
	hash = bit32.bxor(hash, bit32.lshift(hash, 11))
	hash = bit32.band(hash, 0xffffffff)
	hash += bit32.lshift(hash, 15)
	hash = bit32.band(hash, 0xffffffff)

	return ("%08x"):format(hash)
end

function Remediate:_sizeItem(drawCursor: Types.DrawCursor, size: Vector2, textPadding: number?)
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
	drawCursor.LineHeight = 0

	drawCursor.SameLine = false
end

function Remediate:_newElement(class: Types.Class, flags: Types.Flags, ...)
	print(class, flags, ...)
end

function Remediate:_element(class: Types.Class, flags: Types.Flags, ...)
	local window: Types.Window = Internal.FrameData.WindowData.Current

	if window.SkipElements == true then
		return false
	end

	local id: Types.Id = Remediate:_getId()

	local element: Types.Element = window.Elements[id]
	if Internal.ElementData.RedrawElement == true and element ~= nil then
		element:Destroy()
		window.Elements[id] = nil
	end
	if element == nil then
		element = Remediate:_newElement(class, flags, ...)
	end

	element.Frame = Internal.FrameData.Frame

	element:Update(window.DrawCursor.Position, flags, ...)
	Remediate:_sizeItem(window.DrawCursor, element.Size)
end

return Remediate
