local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)
local Hash = require(script.Parent.Parent.Utility.Hash)

local Button = {}
Button.__index = Button
Button.ClassName = "ImGuiButton"

-- local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function Button.new(text: string, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame)
	local self: Types.ImGuiButton = setmetatable({}, Button) :: Types.ImGuiButton

	self.Text = text
	self.Class = "Button"
	self.Id = elementFrame.Id .. ">" .. self.Text
	self.Hash = Hash(self.Id)

	self.State = 0

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Active = true

	self.Size = Vector2.zero

	return self
end

function Button:DrawButton(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Text)
	local boxSize: Vector2 = textSize + 2 * Style.Sizes.FramePadding

	local button: TextLabel = Instance.new("TextLabel")
	button.Name = self.Text
	button.Position = UDim2.fromOffset(position.X, position.Y)
	button.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)

	button.BackgroundColor3 = Style.Colours.Button.Colour
	button.BackgroundTransparency = Style.Colours.Button.Transparency
	button.BorderColor3 = COLOUR3_BLACK
	button.BorderSizePixel = 0

	button.Text = self.Text
	button.FontFace = Style.Font
	button.TextColor3 = Style.Colours.Text.Colour
	button.TextSize = Style.Sizes.TextSize
	button.TextWrapped = false
	button.TextXAlignment = Enum.TextXAlignment.Left

	local padding: UIPadding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, Style.Sizes.FramePadding.X)
	padding.PaddingRight = UDim.new(0, Style.Sizes.FramePadding.X)
	padding.PaddingTop = UDim.new(0, Style.Sizes.FramePadding.Y)
	padding.PaddingBottom = UDim.new(0, Style.Sizes.FramePadding.Y)

	padding.Parent = button

	button.Parent = self.ElementFrame.Instance
	self.Instance = button
	self.Size = boxSize
end

function Button:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawButton(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, position.Y)
	end
end

function Button:UpdateCheckmark(pressed: boolean)
	if self.Instance == nil then
		return
	end

	if pressed == true then
		self.Value[1] = not self.Value[1]
		self.InternalValue = self.Value[1]
		self.Instance.checkbox.ImageTransparency = self.Value[1] == true and Style.Colours.CheckMark.Transparency or 1
	elseif self.InternalValue ~= self.Value[1] then
		self.InternalValue = self.Value[1]
		self.Instance.checkbox.ImageTransparency = self.Value[1] == true and Style.Colours.CheckMark.Transparency or 1
	end
end

function Button:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return Button
