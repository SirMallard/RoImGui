local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local Checkbox = {}
Checkbox.__index = Checkbox
Checkbox.ClassName = "ImGuiCheckbox"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function Checkbox.new(text: string, value: { boolean }, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame)
	local self: Types.ImGuiCheckbox = setmetatable({}, Checkbox) :: Types.ImGuiCheckbox

	self.Class = "Checkbox"
	self.Id = elementFrame.Id .. ">" .. text
	self.Text = text
	self.Value = value
	self.InternalValue = value[1]

	self.State = 0

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Active = true

	self.Size = Vector2.zero

	return self
end

function Checkbox:DrawCheckbox(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Text)
	local boxSize: number = textSize.Y + 2 * Style.Sizes.FramePadding.Y
	local boxInterval: number = boxSize + Style.Sizes.ItemInnerSpacing.X

	local checkbox: Frame = Instance.new("Frame")
	checkbox.Name = self.Text
	checkbox.Position = UDim2.fromOffset(position.X, position.Y)
	checkbox.Size = UDim2.fromOffset(boxInterval + textSize.X, boxSize)

	checkbox.BackgroundColor3 = COLOUR3_WHITE
	checkbox.BackgroundTransparency = 1
	checkbox.BorderColor3 = COLOUR3_BLACK
	checkbox.BorderSizePixel = 0

	local text: TextLabel = Instance.new("TextLabel")
	text.Name = "text"
	text.Position = UDim2.fromOffset(boxInterval, Style.Sizes.FramePadding.Y)
	text.Size = UDim2.new(1, -boxInterval, 0, textSize.Y)

	text.BackgroundColor3 = COLOUR3_WHITE
	text.BackgroundTransparency = 1
	text.BorderColor3 = COLOUR3_BLACK
	text.BorderSizePixel = 0

	text.Text = self.Text
	text.FontFace = Style.Font
	text.TextColor3 = Style.Colours.Text.Colour
	text.TextTransparency = Style.Colours.Text.Transparency
	text.TextSize = Style.Sizes.TextSize
	text.TextWrapped = false
	text.TextXAlignment = Enum.TextXAlignment.Left

	text.Parent = checkbox

	local icon: ImageLabel = Instance.new("ImageLabel")
	icon.Name = "checkbox"
	icon.Size = UDim2.fromOffset(boxSize, boxSize)

	icon.BackgroundColor3 = Style.Colours.FrameBg.Colour
	icon.BackgroundTransparency = Style.Colours.FrameBg.Transparency
	icon.BorderColor3 = COLOUR3_BLACK
	icon.BorderSizePixel = 0

	icon.Image = "rbxassetid://11505661049"
	icon.ImageColor3 = Style.Colours.CheckMark.Colour
	icon.ImageTransparency = self.Value[1] == true and Style.Colours.CheckMark.Transparency or 1

	icon.Parent = checkbox

	checkbox.Parent = self.ElementFrame.Instance
	self.Instance = checkbox
	self.Size = Vector2.new(boxInterval + textSize.X, boxSize)
end

function Checkbox:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawCheckbox(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, position.Y)
	end
end

function Checkbox:UpdateCheckmark(pressed: boolean)
	if self.Instance == nil then
		return
	end

	if pressed == true then
		self.Value[1] = not self.Value[1]
		self.Value[2] = true
		self.InternalValue = self.Value[1]
		self.Instance.checkbox.ImageTransparency = self.Value[1] == true and Style.Colours.CheckMark.Transparency or 1
	elseif self.InternalValue ~= self.Value[1] then
		self.InternalValue = self.Value[1]
		self.Value[2] = true
		self.Instance.checkbox.ImageTransparency = self.Value[1] == true and Style.Colours.CheckMark.Transparency or 1
	elseif self.Value[2] == true then
		self.Value[2] = false
	end
end

function Checkbox:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return Checkbox
