local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)
local Hash = require(script.Parent.Parent.Utility.Hash)

local Text = {}
Text.__index = Text
Text.ClassName = "ImGuiText"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function Text.new(text: string, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame)
	local self: Types.ImGuiText = setmetatable({}, Text) :: Types.ImGuiText

	self.Text = text
	self.Class = "Text"
	self.Id = elementFrame.Id .. ">" .. self.Text
	self.Hash = Hash(self.Id)

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Active = true

	self.Size = Vector2.zero

	return self
end

function Text:DrawText(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Text)

	local text: TextLabel = Instance.new("TextLabel")
	text.Name = self.Text
	text.Position = UDim2.fromOffset(position.X, position.Y)
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

	text.Parent = self.ElementFrame.Instance
	self.Instance = text
	self.Size = textSize
end

function Text:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawText(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, position.Y)
	end
end

function Text:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return Text
