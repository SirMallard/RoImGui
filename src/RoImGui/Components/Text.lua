local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local Text = {}
Text.__index = Text
Text.ClassName = "ImGuiText"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function Text.new(text: string, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame, flags: Types.TextFlags)
	local self: Types.ImGuiText = setmetatable({}, Text) :: Types.ImGuiText

	self.Class = flags.BulletText == true and "BulletText" or "Text"
	self.Id = elementFrame.Id .. ">" .. text
	self.Text = text

	self.ElementFrame = elementFrame
	self.Window = window
	self.LastFrameActive = 0

	self.Flags = flags

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
	local fontSize: number = Style.Sizes.TextSize
	if self.Flags.BulletText == true then
		textSize += Vector2.new(2 * Style.Sizes.FramePadding.X + fontSize, 0)
	end

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
	text.TextSize = fontSize
	text.TextWrapped = false
	text.TextXAlignment = Enum.TextXAlignment.Left

	if self.Flags.BulletText == true then
		local padding: UIPadding = Instance.new("UIPadding")
		padding.Name = "padding"
		padding.PaddingLeft = UDim.new(0, 2 * Style.Sizes.FramePadding.X + fontSize)
		padding.Parent = text

		local bullet: ImageLabel = Instance.new("ImageLabel")
		bullet.Name = "bullet"
		bullet.AnchorPoint = Vector2.new(0.5, 0.5)
		bullet.Position = UDim2.new(0, -Style.Sizes.FramePadding.X - fontSize * 0.5, 0.5, 0)
		bullet.Size = UDim2.fromOffset(math.ceil(fontSize * 0.4), math.ceil(fontSize * 0.4))

		bullet.BackgroundColor3 = COLOUR3_WHITE
		bullet.BackgroundTransparency = 1
		bullet.BorderColor3 = COLOUR3_BLACK
		bullet.BorderSizePixel = 0

		bullet.Image = "rbxassetid://4673889148"
		bullet.ImageColor3 = Style.Colours.Text.Colour
		bullet.ImageTransparency = Style.Colours.Text.Transparency
		bullet.Parent = text
	end

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
