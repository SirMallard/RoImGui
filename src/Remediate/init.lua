local FriendService = game:GetService("FriendService")
local guiService = game:GetService("GuiService")
local runService: RunService = game:GetService("RunService")

local Types = require(script.Types)
local Style = require(script.Utility.Style)
local Internal = require(script.Internal)
local Components = require(script.Components)

local Remediate = {}
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

	Internal:UpdateInput(deltaTime)
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

-- this code is taken from ImGui and I'm don't properly understand what happens.
function Remediate:_sizeItem(drawCursor: Types.DrawCursor, size: Vector2, textPadding: number?)
	local lineOffset: number = (textPadding ~= nil) and (textPadding > 0) and math.max(0, drawCursor.TextLineOffset - textPadding) or 0
	local linePosition: number = (drawCursor.SameLine == true) and drawCursor.PreviousPosition.Y or drawCursor.Position.Y
	local lineHeight: number = math.max(drawCursor.LineHeight, drawCursor.Position.Y - linePosition + size.Y + lineOffset)

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
	Remediate:_sizeItem(window.DrawCursor, element.Properties.Size)

	return
end

function Remediate:Begin(name: string, open: Types.Pointer<boolean, Types.Key>?, flags: Types.Flags?)
	local frameData = Internal.FrameData
	flags = flags or 0

	local id: Types.Id = Remediate:_getId()

	local window: Types.Window = frameData.Windows[id]
	if window == nil then
		window = Components.Window.new(flags, id, name, open or { true })
		frameData.Windows[id] = window
		table.insert(frameData.WindowFocusOrder, window)
		window:Draw()
	end

	table.insert(frameData.WindowStack, window)
	frameData.WindowData.Current = window
	window.Frame = frameData.Frame

	window.SkipElements = window.Properties.Collapsed or (window.Values.Open[window.Values.Key] == false)

	window:Update()

	if window.SkipElements then
		Remediate:End()
	end
end

function Remediate:End()
	local frameData = Internal.FrameData
	assert((#frameData.WindowStack > 0), "Called :End() to many times!")
	assert(frameData.WindowData.Current ~= nil, "Never called :Begin() to set a current window!")

	-- we remove the element from the stack and set the current window to the previous one
	table.remove(frameData.WindowStack)
	frameData.WindowData.Current = frameData.WindowStack[#frameData.WindowStack]
end

return Remediate
