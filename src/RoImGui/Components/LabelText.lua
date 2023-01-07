local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local LabelText = {}
LabelText.__index = LabelText
LabelText.ClassName = "ImGuiLabelText"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function LabelText.new(text: string, label: string, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame)
	local self: Types.ImGuiLabelText = setmetatable({}, LabelText) :: Types.ImGuiLabelText

	self.Class = "LabelText"
	self.Id = elementFrame.Id .. ">" .. text .. "|" .. label
	self.Label = label
	self.Text = text

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Active = true

	self.Size = Vector2.zero

	return self
end

function LabelText:DrawLabelText(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Text)
	local labelSize: Vector2 = #self.Label == 0 and Vector2.zero or Utility.CalculateTextSize(self.Label)

	local labelText: Frame = Instance.new("Frame")
	labelText.Name = self.Text .. "|" .. self.Label
	labelText.Position = UDim2.fromOffset(position.X, position.Y)
	labelText.Size = UDim2.new(1, -position.X, 0, math.max(textSize.Y, labelSize.Y) + 2 * Style.Sizes.FramePadding.Y)

	labelText.BackgroundColor3 = COLOUR3_WHITE
	labelText.BackgroundTransparency = 1
	labelText.BorderColor3 = COLOUR3_BLACK
	labelText.BorderSizePixel = 0

	local text: TextLabel = Instance.new("")

	labelText.Parent = self.ElementFrame.Instance
	self.Instance = labelText
	self.Size = textSize
end

function LabelText:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawLabelText(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, position.Y)
	end
end

function LabelText:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return LabelText
