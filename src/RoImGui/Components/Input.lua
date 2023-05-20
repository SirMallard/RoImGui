local Types = require(script.Parent.Parent.Types)
local Flags = require(script.Parent.Parent.Flags)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local Input = {}
Input.__index = Input
Input.ClassName = "ImGuiInput"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function Input.new(
	label: string,
	value: { string },
	window: Types.ImGuiWindow,
	elementFrame: Types.ElementFrame,
	flags: Types.Flag,
	placeholder: string?
)
	local self: Types.ImGuiInput = setmetatable({}, Input) :: Types.ImGuiInput

	self.Class = "Input"
	self.Id = elementFrame.Id .. ">" .. label
	self.Label = label
	self.Value = value
	self.InternalValue = value[1]
	self.HasLabel = #self.Label > 0

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Flags = flags
	self.PlaceholderText = placeholder

	self.Active = true

	self.Size = Vector2.zero

	return self
end

function Input:DrawInputText(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Value[1])
	local labelSize: Vector2 = (self.HasLabel == true) and Utility.CalculateTextSize(self.Label) or Vector2.zero

	local labelText: Frame = Instance.new("Frame")
	labelText.Name = self.Label
	labelText.Position = UDim2.fromOffset(position.X, position.Y)
	labelText.Size = UDim2.new(1, -position.X, 0, math.max(textSize.Y, labelSize.Y) + 2 * Style.Sizes.FramePadding.Y)

	labelText.BackgroundColor3 = COLOUR3_WHITE
	labelText.BackgroundTransparency = 1
	labelText.BorderColor3 = COLOUR3_BLACK
	labelText.BorderSizePixel = 0

	local textbox: TextBox = Instance.new("TextBox")
	textbox.Name = "textbox"
	textbox.Position = UDim2.fromOffset(0, 0)
	textbox.Size = UDim2.new(Style.Sizes.ItemWidthScale, 0, 0, textSize.Y + 2 * Style.Sizes.FramePadding.Y)

	textbox.BackgroundColor3 = Style.Colours.FrameBg.Colour
	textbox.BackgroundTransparency = Style.Colours.FrameBg.Transparency
	textbox.BorderColor3 = COLOUR3_BLACK
	textbox.BorderSizePixel = 0

	textbox.Text = self.Value[1]
	textbox.FontFace = Style.Font
	textbox.TextColor3 = Style.Colours.Text.Colour
	textbox.TextTransparency = Style.Colours.Text.Transparency
	textbox.TextSize = Style.Sizes.TextSize
	textbox.TextWrapped = false
	textbox.TextXAlignment = Enum.TextXAlignment.Left
	textbox.MultiLine = false
	textbox.ClearTextOnFocus = false
	textbox.ClipsDescendants = true
	textbox.CursorPosition = -1

	if Flags.Enabled(self.Flags, Flags.InputFlags.PlaceHolderText) == true then
		local placeholder: TextLabel = Instance.new("TextLabel")
		placeholder.Name = "placeholder"
		placeholder.Position = UDim2.fromOffset(0, 0)
		placeholder.Size = UDim2.fromScale(1, 1)

		placeholder.BackgroundColor3 = COLOUR3_WHITE
		placeholder.BackgroundTransparency = 1
		placeholder.BorderColor3 = COLOUR3_BLACK
		placeholder.BorderSizePixel = 0

		placeholder.Text = self.PlaceholderText
		placeholder.FontFace = Style.Font
		placeholder.TextColor3 = Style.Colours.TextDisabled.Colour
		placeholder.TextTransparency = (#self.InternalValue == 0) and Style.Colours.TextDisabled.Transparency or 1
		placeholder.TextSize = Style.Sizes.TextSize
		placeholder.TextWrapped = false
		placeholder.TextXAlignment = Enum.TextXAlignment.Left

		placeholder.Parent = textbox
	end

	local padding: UIPadding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, Style.Sizes.FramePadding.Y)
	padding.PaddingBottom = UDim.new(0, Style.Sizes.FramePadding.Y)
	padding.PaddingLeft = UDim.new(0, Style.Sizes.FramePadding.X)
	padding.PaddingRight = UDim.new(0, Style.Sizes.FramePadding.X)

	padding.Parent = textbox

	textbox.Parent = labelText

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

function Input:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawInputText(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, position.Y)
	end
end

function Input:UpdateText()
	if self.Instance == nil then
		return
	end

	if self.InternalValue ~= self.Value[1] then
		self.InternalValue = self.Value[1]
		self.Value[2] = true

		if Flags.Enabled(self.Flags, Flags.InputFlags.PlaceHolderText) == true then
			self.Instance.textbox.placeholder.TextTransparency = (#self.InternalValue == 0)
					and Style.Colours.TextDisabled.Transparency
				or 1
		end

		if self.Instance.textbox.Text ~= tostring(self.Value[1]) then
			self.Instance.textbox.Text = tostring(self.Value[1])
		end
	elseif self.Value[2] == true then
		self.Value[2] = nil
	end
end

function Input:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return Input
