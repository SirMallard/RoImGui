local guiService = game:GetService("GuiService")
local runService: RunService = game:GetService("RunService")

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
	Remediate:_sizeItem(window.DrawCursor, element.Size)

	return
end

function Remediate:Begin() end

return Remediate
