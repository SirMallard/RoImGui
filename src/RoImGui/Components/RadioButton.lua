local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local RadioButton = {}
RadioButton.__index = RadioButton
RadioButton.ClassName = "ImGuiRadioButton"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function RadioButton.new(
	text: string,
	buttonValue: number,
	value: Types.NumberPointer,
	window: Types.ImGuiWindow,
	elementFrame: Types.ElementFrame
)
	local self: Types.ImGuiRadioButton = setmetatable({}, RadioButton) :: Types.ImGuiRadioButton

	self.Class = "RadioButton"
	self.Id = elementFrame.Id .. ">" .. text
	self.Text = text
	self.ButtonValue = buttonValue
	self.Value = value
	self.InternalValue = if value[2] ~= nil then value[1][value[2]] else value[1]

	self.State = 0

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Active = true

	self.Size = Vector2.zero

	return self
end

function RadioButton:DrawRadioButton(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Text)
	local boxSize: number = textSize.Y + 2 * Style.Sizes.FramePadding.Y
	local padding: number = math.max(1, math.floor(boxSize / 6))

	local radioButton: Frame = Instance.new("Frame")
	radioButton.Name = self.Text
	radioButton.Position = UDim2.fromOffset(position.X, position.Y)
	radioButton.Size = UDim2.fromOffset(boxSize + Style.Sizes.ItemInnerSpacing.X + textSize.X, boxSize)

	radioButton.BackgroundColor3 = COLOUR3_WHITE
	radioButton.BackgroundTransparency = 1
	radioButton.BorderColor3 = COLOUR3_BLACK
	radioButton.BorderSizePixel = 0

	local radio: ImageLabel = Instance.new("ImageLabel")
	radio.Name = "radio"
	radio.Size = UDim2.fromOffset(boxSize, boxSize)

	radio.BackgroundColor3 = COLOUR3_WHITE
	radio.BackgroundTransparency = 1
	radio.BorderColor3 = COLOUR3_BLACK
	radio.BorderSizePixel = 0

	radio.Image = Style.Images.Circle
	radio.ImageColor3 = Style.Colours.FrameBg.Colour
	radio.ImageTransparency = Style.Colours.FrameBg.Transparency

	radio.Parent = radioButton

	local button: ImageLabel = Instance.new("ImageLabel")
	button.Name = "button"
	button.Position = UDim2.fromOffset(padding, padding)
	button.Size = UDim2.fromOffset(boxSize - 2 * padding, boxSize - 2 * padding)

	button.BackgroundColor3 = COLOUR3_WHITE
	button.BackgroundTransparency = 1
	button.BorderColor3 = COLOUR3_BLACK
	button.BorderSizePixel = 0

	button.Image = Style.Images.Circle
	button.ImageColor3 = Style.Colours.CheckMark.Colour
	button.ImageTransparency = (
		(if self.Value[2] ~= nil then self.Value[1][self.Value[2]] else self.Value[1]) == self.ButtonValue
	)
			and Style.Colours.CheckMark.Transparency
		or 1

	button.Parent = radio

	local text: TextLabel = Instance.new("TextLabel")
	text.Name = "text"
	text.Position = UDim2.fromOffset(boxSize + Style.Sizes.ItemInnerSpacing.X, Style.Sizes.FramePadding.Y)
	text.Size = UDim2.fromOffset(textSize.X, textSize.Y)

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

	text.Parent = radioButton

	radioButton.Parent = self.ElementFrame.Instance
	self.Instance = radioButton
	self.Size = Vector2.new(boxSize + Style.Sizes.ItemInnerSpacing.X + textSize.X, boxSize)
end

function RadioButton:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawRadioButton(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, position.Y)
	end
end

function RadioButton:UpdateRadioButton()
	if self.Instance == nil then
		return
	end

	local value: number = if self.Value[2] ~= nil then self.Value[1][self.Value[2]] else self.Value[1]
	if self.InternalValue ~= value then
		self.InternalValue = value
		self.Value[0] = true
		self.Instance.radio.button.ImageTransparency = value == self.ButtonValue
				and Style.Colours.CheckMark.Transparency
			or 1
	elseif self.Value[0] == true then
		self.Value[0] = nil
	end
end

function RadioButton:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return RadioButton
