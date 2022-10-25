local textService: TextService = game:GetService("TextService")
local httpService: HttpService = game:GetService("HttpService")

local Style = require(script.Parent.Style)

local Utility = {}

Utility.DefaultFramePaddedHeight = Style.Sizes.TextMinHeight + 2 * Style.Sizes.FramePadding.Y

local largeVector2: Vector2 = Vector2.new(4096, 4096)
local mouseX: number = 0
local mouseY: number = 0

-- Should be called every frame so I can update mouse positions and any constants that are used quite frequently
function Utility.Update(mousePosition: Vector2)
	mouseX = mousePosition.X
	mouseY = mousePosition.Y
	Utility.DefaultFramePaddedHeight = Style.Sizes.TextMinHeight + 2 * Style.Sizes.FramePadding.Y
end

function Utility.IsCursorInBox(absolutePosition: Vector2, absoluteSize: Vector2): (boolean)
	return (mouseX >= absolutePosition.X)
		and (mouseX <= absolutePosition.X + absoluteSize.X)
		and (mouseY >= absolutePosition.Y)
		and (mouseY <= absolutePosition.Y + absoluteSize.Y)
end

function Utility.CalculateTextSize(text: string): (Vector2)
	return textService:GetTextSize(text, Style.Sizes.TextSize, Enum.Font.Arial, largeVector2)
end

function Utility.GenerateRandomId()
	return httpService:GenerateGUID(false):gsub("=", "")
end

return Utility
