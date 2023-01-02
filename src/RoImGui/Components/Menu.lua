local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local Menu = {}
Menu.__index = Menu
Menu.ClassName = "Menu"

-- local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function Menu.new(text: string, window: Types.ImGuiWindow, menubar: Types.WindowMenubar)
	local self: Types.ImGuiMenu = setmetatable({}, Menu) :: Types.ImGuiMenu

	self.Class = "Menu"
	self.Id = menubar.Id .. ">" .. text
	self.Text = text

	self.State = 0

	self.Menubar = menubar
	self.Window = window
	self.LastFrameActive = 0

	self.Active = false

	self.Size = Vector2.zero

	return self
end

function Menu:DrawMenu(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.Menubar.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Text)

	local menu: TextLabel = Instance.new("TextLabel")
	menu.Name = self.Text
	menu.Position = UDim2.fromOffset(position.X, 0)
	menu.Size = UDim2.new(0, textSize.X + 2 * Style.Sizes.ItemSpacing.X, 1, 0)

	menu.BackgroundColor3 = Style.Colours.Transparent.Colour
	menu.BackgroundTransparency = Style.Colours.Transparent.Transparency
	menu.BorderColor3 = COLOUR3_BLACK
	menu.BorderSizePixel = 0

	menu.Text = self.Text
	menu.FontFace = Style.Font
	menu.TextColor3 = Style.Colours.Text.Colour
	menu.TextTransparency = Style.Colours.Text.Transparency
	menu.TextSize = Style.Sizes.TextSize
	menu.TextWrapped = false

	menu.Parent = self.Menubar.Instance
	self.Instance = menu
	self.Size =
		Vector2.new(textSize.X + 2 * Style.Sizes.ItemSpacing.X, Style.Sizes.TextSize + 2 * Style.Sizes.FramePadding.Y)
end

function Menu:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawMenu(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, 0)
	end
end

function Menu:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return Menu
