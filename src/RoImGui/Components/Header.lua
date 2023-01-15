local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local Header = {}
Header.__index = Header
Header.ClassName = "CollapsingHeader"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function Header.new(text: string, value: { boolean }, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame)
	local self: Types.ImGuiHeader = setmetatable({}, Header) :: Types.ImGuiHeader

	self.Text = text
	self.Class = "CollapsingHeader"
	self.Id = elementFrame.Id .. ">" .. self.Text
	self.Value = value
	self.InternalValue = value[1]

	self.State = 0

	self.ElementFrame = elementFrame
	self.Window = window

	self.Active = false
	self.LastFrameActive = 0

	self.Size = Vector2.zero

	return self
end

function Header:DrawHeader(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Text)
	local offset: number = math.floor(0.5 * Style.Sizes.WindowPadding.X)
	local padding: number = 2 * Style.Sizes.FramePadding.X
	local height: number = 2 * Style.Sizes.FramePadding.Y

	local header: Frame = Instance.new("Frame")
	header.Name = self.Text
	header.Position = UDim2.fromOffset(position.X - offset, position.Y)
	header.Size = UDim2.new(1, offset - position.X, 0, Style.Sizes.TextSize + height)

	header.BackgroundColor3 = Style.Colours.Header.Colour
	header.BackgroundTransparency = Style.Colours.Header.Transparency
	header.BorderColor3 = COLOUR3_BLACK
	header.BorderSizePixel = 0

	local text: TextLabel = Instance.new("TextLabel")
	text.Name = "text"
	text.Position = UDim2.fromOffset(Style.Sizes.TextSize + offset + padding, Style.Sizes.FramePadding.Y)
	text.Size = UDim2.fromOffset(textSize.X, Style.Sizes.TextSize)

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

	text.Parent = header

	local dropdown: ImageLabel = Instance.new("ImageLabel")
	dropdown.Name = "dropdown"
	dropdown.Position = UDim2.fromOffset(1.5 * Style.Sizes.FramePadding.X, 0.5 * Style.Sizes.FramePadding.Y)
	dropdown.Size = UDim2.fromOffset(
		Style.Sizes.TextSize + Style.Sizes.FramePadding.Y,
		Style.Sizes.TextSize + Style.Sizes.FramePadding.Y
	)
	dropdown.Rotation = (self.Value[1] == true) and 0 or -90

	dropdown.BackgroundColor3 = COLOUR3_WHITE
	dropdown.BackgroundTransparency = 1
	dropdown.BorderColor3 = COLOUR3_BLACK
	dropdown.BorderSizePixel = 0

	dropdown.Image = Style.Images.Dropdown
	dropdown.ImageColor3 = Style.Colours.Text.Colour
	dropdown.ImageTransparency = Style.Colours.Text.Transparency

	dropdown.Parent = header

	header.Parent = self.ElementFrame.Instance
	self.Instance = header
	self.Size = Vector2.new(textSize.X + padding + Style.Sizes.TextSize + offset, Style.Sizes.TextSize + height)
end

function Header:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawHeader(position)
	else
		local offset: number = math.floor(0.5 * Style.Sizes.WindowPadding.X)
		self.Instance.Position = UDim2.fromOffset(position.X - offset, position.Y)
		self.Instance.Size = UDim2.new(1, offset - position.X, 0, Style.Sizes.TextSize + 2 * Style.Sizes.FramePadding.Y)
	end
end

function Header:UpdateHeader(pressed: boolean)
	if self.Instance == nil then
		return
	end

	if pressed == true then
		self.Value[1] = not self.Value[1]
		self.InternalValue = self.Value[1]
		self.Instance.dropdown.Rotation = (self.Value[1] == true) and 0 or -90
	elseif self.InternalValue ~= self.Value[1] then
		self.InternalValue = self.Value[1]
		self.Instance.dropdown.Rotation = (self.Value[1] == true) and 0 or -90
	end
end

function Header:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return Header
