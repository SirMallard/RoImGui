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
	self.HasLabel = #self.Label > 0

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
	local labelSize: Vector2 = (self.HasLabel == true) and Utility.CalculateTextSize(self.Label) or Vector2.zero

	local labelText: Frame = Instance.new("Frame")
	labelText.Name = self.Text .. "|" .. self.Label
	labelText.Position = UDim2.fromOffset(position.X, position.Y)
	labelText.Size = UDim2.new(1, -position.X, 0, math.max(textSize.Y, labelSize.Y) + 2 * Style.Sizes.FramePadding.Y)

	labelText.BackgroundColor3 = COLOUR3_WHITE
	labelText.BackgroundTransparency = 1
	labelText.BorderColor3 = COLOUR3_BLACK
	labelText.BorderSizePixel = 0

	local text: TextLabel = Instance.new("TextLabel")
	text.Name = "text"
	text.Position = UDim2.fromOffset(Style.Sizes.FramePadding.X, Style.Sizes.FramePadding.Y)
	text.Size = UDim2.new(Style.Sizes.ItemWidthScale, 0, 0, textSize.Y)

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

	text.Parent = labelText

	if self.HasLabel == true then
		local label: TextLabel = Instance.new("TextLabel")
		label.Name = "label"
		label.Position =
			UDim2.new(Style.Sizes.ItemWidthScale, Style.Sizes.FramePadding.X, 0, Style.Sizes.FramePadding.Y)
		label.Size = UDim2.new(1 - Style.Sizes.ItemWidthScale, -Style.Sizes.FramePadding.X, 0, labelSize.Y)

		label.BackgroundColor3 = COLOUR3_WHITE
		label.BackgroundTransparency = 1
		label.BorderColor3 = COLOUR3_BLACK
		label.BorderSizePixel = 0

		label.Text = self.Label
		label.FontFace = Style.Font
		label.TextColor3 = Style.Colours.Text.Colour
		label.TextTransparency = Style.Colours.Text.Transparency
		label.TextSize = Style.Sizes.TextSize
		label.TextWrapped = false
		label.TextXAlignment = Enum.TextXAlignment.Left

		label.Parent = labelText
	end

	labelText.Parent = self.ElementFrame.Instance
	self.Instance = labelText
	self.Size = Vector2.new(1, math.max(textSize.Y, labelSize.Y) + 2 * Style.Sizes.FramePadding.Y)
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
