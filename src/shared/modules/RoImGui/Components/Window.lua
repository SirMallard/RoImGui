local Style = require(script.Parent.Parent.Types.Style)
local Types = require(script.Parent.Parent.Types.Types)
local Utility = require(script.Parent.Parent.Utility)
local ImGuiInternal = require(script.Parent.Parent.ImGuiInternal)

local Window = {}
Window.__index = Window
Window.ClassName = "ImGuiWindow"

local function createDropdown(collapsed: boolean): (ImageLabel)
	local dropdown: ImageLabel = Instance.new("ImageLabel")
	dropdown.Name = "dropdown"
	dropdown.Position = UDim2.fromOffset(Style.Sizes.WindowPadding.X - 1, Style.Sizes.WindowPadding.Y - 2)
	dropdown.Size = UDim2.fromOffset(15, 15)
	dropdown.Rotation = (collapsed == true) and -90 or 0

	dropdown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dropdown.BackgroundTransparency = 1
	dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
	dropdown.BorderSizePixel = 0

	dropdown.Image = "rbxassetid://4673889148"
	dropdown.ImageColor3 = Style.Colours.Text.Color
	dropdown.ImageTransparency = Style.Colours.Text.Transparency

	local icon: ImageLabel = Instance.new("ImageLabel")
	icon.Name = "icon"
	icon.Position = UDim2.fromScale(6, 5)
	icon.Size = UDim2.fromOffset(11, 9)

	icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	icon.BackgroundTransparency = 1
	icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	icon.BorderSizePixel = 0

	icon.Image = "rbxassetid://1248849582"
	icon.ImageColor3 = Style.Colours.Text.Color
	icon.ImageTransparency = Style.Colours.Text.Transparency
	icon.Parent = dropdown

	return dropdown
end

local function createClose(windowWidth: number, buttonColour): (ImageLabel)
	local close: ImageLabel = Instance.new("ImageLabel")
	close.Name = "close"
	close.Position = UDim2.fromOffset(windowWidth - Style.Sizes.FramePadding.X - 14, Style.Sizes.WindowPadding.Y - 2)
	close.Size = UDim2.fromOffset(15, 15)

	close.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	close.BackgroundTransparency = 1
	close.BorderColor3 = Color3.fromRGB(0, 0, 0)
	close.BorderSizePixel = 0

	close.Image = "rbxassetid://4673889148"
	close.ImageColor3 = Style.Colours.ButtonHovered.Color
	close.ImageTransparency = Style.Colours.ButtonHovered.Transparency

	local icon = Instance.new("ImageLabel")
	icon.Name = "close"
	icon.Position = UDim2.fromOffset(1, 1)
	icon.Size = UDim2.fromOffset(13, 13)

	icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	icon.BackgroundTransparency = 1
	icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	icon.BorderSizePixel = 0

	icon.Image = "rbxassetid://3926305904"
	icon.ImageRectOffset = Vector2.new(284, 4)
	icon.ImageRectSize = Vector2.new(24, 24)
	icon.ImageColor3 = Style.Colours.Text.Color
	icon.ImageTransparency = Style.Colours.Text.Transparency
	icon.Parent = close

	return close
end

function Window.new(windowName: string, parentWindow: Types.ImGuiWindow?, flags: any?): (Types.ImGuiWindow)
	local self: Types.ImGuiWindow = setmetatable({}, Window)

	self.Name = windowName
	self.Id = windowName

	self.ParentWindow = parentWindow
	self.RootWindow = parentWindow and parentWindow.RootWindow or nil
	self.WriteAccessed = false

	self.LastFrameActive = 0
	self.FocusOrder = 0

	self.Flags = flags

	self.DrawCursor = {
		Position = Vector2.zero, -- Kept locally to the frame
		StartPosition = Vector2.zero,
		MaximumPosition = Vector2.new(60, 60),
		PreviousPosition = Vector2.zero,
	}

	self.Position = Vector2.new(60, 60) -- Default starting positon.
	self.Size = Vector2.new(60, 60)
	self.MinimumSize = Vector2.new(Style.Sizes.WindowPadding.X * 2 + Style.Sizes.ItemInnerSpacing.X + 30, 60)

	self.Active = true
	self.WasActive = true
	self.CanCollapse = true
	self.CanClose = true
	self.Collapsed = false
	self.Closed = { false }
	self.Open = { true }

	self.DropdownId = Utility.GenerateRandomId()
	self.CloseId = Utility.GenerateRandomId()

	self.Menubar = nil

	self.Instance = nil

	return self
end

function Window:Update(stack: number)
	self.MinimumSize = Vector2.new(Style.Sizes.WindowPadding.X * 2 + Style.Sizes.ItemInnerSpacing.X + 30, 60)
	if self.Size.X < self.MinimumSize.X then
		self.Size = Vector2.new(self.MinimumSize.X, self.Size.Y)
	end
	if self.Size.Y < self.MinimumSize.Y then
		self.Size = Vector2.new(self.Size.X, self.MinimumSize.Y)
	end

	local minimumHeight: number = Utility.DefaultFramePaddedHeight
	if self.Menubar ~= nil then
		minimumHeight += Utility.DefaultFramePaddedHeight
	end

	self.Instance.Name = "window:" .. self.Name
	self.Instance.Position = UDim2.fromOffset(self.Position.X, self.Position.Y)
	self.Instance.Size = UDim2.fromOffset(self.Size.X, minimumHeight + self.Size.Y)

	local title: Frame = self.Instance.title
	title.Size = UDim2.fromOffset(self.Size.X, Utility.DefaultFramePaddedHeight)
	if self.Open[1] == false then
		title.BackgroundColor3 = Style.Colours.TitleBgCollapsed.Color
		title.Transparency = Style.Colours.TitleBgCollapsed.Transparency
	else
		title.BackgroundColor3 = Style.Colours.TitleBg.Color
		title.Transparency = Style.Colours.TitleBg.Transparency
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Name)
	local text: TextLabel = self.Instance.title.text
	text.Position = UDim2.fromOffset(
		Style.Sizes.WindowPadding.X + (self.CanCollapse and (15 + Style.Sizes.ItemInnerSpacing.X) or 0),
		Style.Sizes.WindowPadding.Y
	)
	text.Size = UDim2.fromOffset(
		math.min(
			textSize.X,
			self.Size.X
				- Style.Sizes.WindowPadding.X
				- ((self.CanCollapse == true) and 15 + Style.Sizes.ItemInnerSpacing.X or 0)
				- ((self.CanClose == true) and 15 + Style.Sizes.ItemInnerSpacing.X or 0)
		),
		Style.Sizes.TextSize
	)
	text.Text = self.Name
	text.TextColor3 = Style.Colours.Text.Color
	text.TextTransparency = Style.Colours.Text.Transparency
	text.TextSize = Style.Sizes.TextSize

	local dropdown: ImageLabel? = self.Instance.title.dropdown
	if dropdown ~= nil then
		if self.CanCollapse == false then
			dropdown:Destroy()
		else
			dropdown.Position = UDim2.fromOffset(Style.Sizes.WindowPadding.X - 1, Style.Sizes.WindowPadding.Y - 2)
			dropdown.Size = UDim2.fromOffset(15, 15)
			dropdown.Rotation = (self.Collapsed == true) and -90 or 0
			dropdown.ImageColor3 = Style.Colours.Text.Color
			dropdown.ImageTransparency = 1
			dropdown.icon.ImageColor3 = Style.Colours.Text.Color
			dropdown.icon.ImageTransparency = Style.Colours.Text.Transparency
		end
	elseif self.CanCollapse == true then
		dropdown = createDropdown(self.Collapsed)
		dropdown.Parent = title
	end

	local close: ImageLabel? = self.Instance.title.close
	local buttonColour: Types.Color4Type = if (ImGuiInternal.HoverId == self.CloseId)
			and (ImGuiInternal.ActiveId == self.CloseId)
		then Style.Colours.ButtonActive
		elseif ImGuiInternal.HoverId == self.CloseId then Style.Colours.ButtonHovered
		else Style.Colours.Transparent
	if close ~= nil then
		if self.CanClose == false then
			close:Destroy()
		else
			close.Position =
				UDim2.fromOffset(self.Size.X - Style.Sizes.FramePadding.X - 14, Style.Sizes.WindowPadding.Y - 2)
			close.Size = UDim2.fromOffset(15, 15)
			close.ImageColor3 = buttonColour.Color
			close.ImageTransparency = buttonColour.Transparency
			close.icon.ImageColor3 = Style.Colours.Text.Color
			close.icon.ImageTransparency = Style.Colours.Text.Transparency
		end
	elseif self.CanClose == true then
		close = createClose(self.Size.X, buttonColour)
		close.Parent = title
	end
end

function Window:Draw(stack: number?)
	local window: Frame = Instance.new("Frame")
	window.Name = "window:" .. self.Name
	window.ZIndex = stack or window.ZIndex

	window.Position = UDim2.fromOffset(self.Position.X, self.Position.Y)
	window.Size = UDim2.fromOffset(self.Size.X, self.Size.Y)

	window.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	window.BackgroundTransparency = 1
	window.BorderColor3 = Color3.fromRGB(0, 0, 0)
	window.BorderSizePixel = 0

	local stroke: UIStroke = Instance.new("UIStroke")
	stroke.Name = "stroke"
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Style.Colours.Border.Color
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.Transparency = Style.Colours.Border.Transparency
	stroke.Parent = window

	local title: Frame = Instance.new("Frame")
	title.Name = "title"
	title.Position = UDim2.fromScale(0, 0)
	title.Size = UDim2.fromOffset(self.Size.X, Utility.DefaultFramePaddedHeight)

	title.BackgroundColor3 = (self.Open[1] == true) and Style.Colours.TitleBg.Color
		or Style.Colours.TitleBgCollapsed.Color
	title.Transparency = (self.Open[1] == true) and Style.Colours.TitleBg.Transparency
		or Style.Colours.TitleBgCollapsed.Transparency
	title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderSizePixel = 0	

	local textSize: Vector2 = Utility.CalculateTextSize(self.Name)
	local text: TextLabel = Instance.new("TextLabel")
	text.Name = "text"
	text.Position = UDim2.fromOffset(
		Style.Sizes.WindowPadding.X + (self.CanCollapse and (15 + Style.Sizes.ItemInnerSpacing.X) or 0),
		Style.Sizes.WindowPadding.Y
	)
	text.Size = UDim2.fromOffset(
		math.min(
			textSize.X,
			self.Size.X
				- Style.Sizes.WindowPadding.X
				- ((self.CanCollapse == true) and 15 + Style.Sizes.ItemInnerSpacing.X or 0)
				- ((self.CanClose == true) and 15 + Style.Sizes.ItemInnerSpacing.X or 0)
		),
		Style.Sizes.TextSize
	)

	text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	text.BackgroundTransparency = 1
	text.BorderColor3 = Color3.fromRGB(0, 0, 0)
	text.BorderSizePixel = 0

	text.Text = self.Name
	text.FontFace = Font.fromEnum(Enum.Font.Arial)
	text.TextColor3 = Style.Colours.Text.Color
	text.TextSize = Style.Sizes.TextSize
	text.TextWrapped = false
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Parent = title

	if self.CanCollapse == true then
		local dropdown: ImageLabel = createDropdown(self.Collapsed)
		dropdown.Parent = title
	end

	if self.CanClose == true then
		local close: ImageLabel = createClose(self.Size.X)
		close.Parent = title
	end

	self.Instance = window
end

--function Window:SetActive(active: boolean)
--	self.Active = active
--end

function Window:Destroy()
	if self.Instance then
		self.Instance:Destroy()
	end

	setmetatable(self, nil)
end

return Window
