local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local Button = {}
Button.__index = Button
Button.ClassName = "ImGuiButton"

-- local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function Button.new(text: string, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame)
	local self: Types.ImGuiButton = setmetatable({}, Button) :: Types.ImGuiButton

	self.Class = "Button"
	self.Id = elementFrame.Id .. ">" .. text
	self.Text = text

	self.State = 0

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Active = true

	self.Size = Vector2.zero

	return self
end

function Button:DrawButton(position: Vector2, width: number?)
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
	button.Size = UDim2.fromOffset(width or boxSize.X, boxSize.Y)

	button.BackgroundColor3 = Style.Colours.Button.Colour
	button.BackgroundTransparency = Style.Colours.Button.Transparency
	button.BorderColor3 = COLOUR3_BLACK
	button.BorderSizePixel = 0

	button.Text = self.Text
	button.FontFace = Style.Font
	button.TextColor3 = Style.Colours.Text.Colour
	button.TextTransparency = Style.Colours.Text.Transparency
	button.TextSize = Style.Sizes.TextSize
	button.TextWrapped = false
	button.TextXAlignment = Enum.TextXAlignment.Center

	local padding: UIPadding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, Style.Sizes.FramePadding.X)
	padding.PaddingRight = UDim.new(0, Style.Sizes.FramePadding.X)
	padding.PaddingTop = UDim.new(0, Style.Sizes.FramePadding.Y)
	padding.PaddingBottom = UDim.new(0, Style.Sizes.FramePadding.Y)

	padding.Parent = button

	button.Parent = self.ElementFrame.Instance
	self.Instance = button
	self.Size = button.AbsoluteSize
end

function Button:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawButton(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, position.Y)
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
