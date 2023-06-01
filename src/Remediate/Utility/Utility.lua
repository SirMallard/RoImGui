local contentProvider = game:GetService("ContentProvider")
local textService = game:GetService("TextService")
local methods = {}

local Style = require(script.Parent.Style)
local Types = require(script.Parent.Parent.Types)

contentProvider:PreloadAsync({ Style.Font })
local TEXT_PARAMS: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
TEXT_PARAMS.Font = Style.Font
TEXT_PARAMS.Size = Style.Sizes.TextSize
TEXT_PARAMS.Width = 4096

local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)

function methods.getTextSize(text: string)
	TEXT_PARAMS.Text = text
	return textService:GetTextBoundsAsync(TEXT_PARAMS)
end

function methods.applyStyle(instance: GuiObject, style)
	instance.BackgroundColor3 = style.Colour or WHITE
	instance.BackgroundTransparency = style.Transparency or 1
	instance.BorderColor3 = BLACK
	instance.BorderSizePixel = 0
end

function methods.applyImageStyle(instance: ImageLabel, style)
	instance.ImageColor3 = style.Colour or WHITE
	instance.ImageTransparency = style.Transparency or 1
end

function methods.applyText(instance: TextLabel)
	instance.FontFace = Style.Font
	instance.TextColor3 = Style.Colours.Text.Colour
	instance.TextSize = Style.Sizes.TextSize
	instance.TextWrapped = false
	instance.TextXAlignment = Enum.TextXAlignment.Left
end

function methods.newPadding(padding: Vector2)
	local instance: UIPadding = Instance.new("UIPadding")
	instance.Name = "padding"
	instance.PaddingTop = UDim.new(0, padding.Y)
	instance.PaddingBottom = UDim.new(0, padding.Y)
	instance.PaddingLeft = UDim.new(0, padding.X)
	instance.PaddingRight = UDim.new(0, padding.X)
	return instance
end

return methods
