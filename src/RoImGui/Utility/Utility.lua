local textService: TextService = game:GetService("TextService")
local contentProvider: ContentProvider = game:GetService("ContentProvider")

local Style = require(script.Parent.Style)

local Utility = {}

Utility.DefaultFramePaddedHeight = Style.Sizes.TextMinHeight + 2 * Style.Sizes.FramePadding.Y

contentProvider:PreloadAsync({ Style.Font.Family })
local TEXT_PARAMS: GetTextBoundsParams = Instance.new("GetTextBoundsParams")
TEXT_PARAMS.Font = Style.Font
TEXT_PARAMS.Size = Style.Sizes.TextSize
TEXT_PARAMS.Width = 4096

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
	TEXT_PARAMS.Text = text
	return textService:GetTextBoundsAsync(TEXT_PARAMS)
end

return Utility
