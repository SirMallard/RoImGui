local Style = require(script.Parent.Parent.Utility.Style)
local Types = require(script.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Utility.Utility)
local ImGuiInternal: Types.ImGuiInternal = require(script.Parent.Parent.ImGuiInternal)

local Window = {}
Window.__index = Window
Window.ClassName = "ImGuiWindow"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

--[[
	Notes on drawing:
		- An entire window draw is called very rarely:
			- Collapsed or un-collpased
			- Closed or opened
			- Repurpose of the window?
			
		- Title:
			- Redraw:
				- Window name change
			- Updated:
				- Button hover or highlights.
]]

function Window.new(windowName: string, parentWindow: Types.ImGuiWindow?, flags: Types.WindowFlags): (Types.ImGuiWindow)
	local self: Types.ImGuiWindow = setmetatable({}, Window) :: Types.ImGuiWindow

	self.Name = windowName
	self.Class = "Window"
	self.Id = windowName

	self.ParentWindow = parentWindow or nil
	self.RootWindow = parentWindow and parentWindow.RootWindow or nil
	self.ChildWindows = {}

	self.LastFrameActive = -1
	self.FocusOrder = 0

	self.Flags = flags

	self.Position = Vector2.new(60, 60) -- Default starting positon.
	self.Size = Vector2.new(60, 120)
	self.MinimumSize = Vector2.new(Style.Sizes.WindowPadding.X * 2 + Style.Sizes.ItemInnerSpacing.X + 30, 60)

	self.State = 0
	self.Active = true
	self.WasActive = true
	self.Appearing = false
	self.Collapsed = false
	self.Open = { true }
	self.SkipElements = false

	self.RedrawThisFrame = false -- DO NOT SET, changed internally based on .RedrawNextFrame
	self.RedrawNextFrame = false -- Calls a complete redraw for the next frame. Everything gets wiped. Used when

	self.Window = {
		Title = {
			Class = "Title",
			Id = self.Id .. ">Title",
			Text = "",
			Collapse = {
				Class = "Button",
				Id = self.Id .. ">Title>Collapse",
				State = 0,
			},
			Close = {
				Class = "Button",
				Id = self.Id .. ">Title>Close",
				State = 0,
			},
			MinimumSize = Vector2.new(0, 0),
		},
		Menubar = {
			Class = "Menubar",
			Id = self.Id .. ">Menubar",
			Menus = {},
			MinimumSize = Vector2.new(0, 0),
			Appending = false,

			DrawCursor = {
				Position = Vector2.zero,
				PreviousPosition = Vector2.zero,

				StartPosition = Vector2.zero,
				MaximumPosition = Vector2.zero,
			},
		},
		Frame = {
			Class = "ElementFrame",
			Id = self.Id .. ">Frame",
			MinimumSize = Vector2.new(0, Style.Sizes.TextSize),
			DrawCursor = {
				Position = Vector2.zero, -- Kept locally to the frame
				PreviousPosition = Vector2.zero,

				StartPosition = Vector2.zero,
				MaximumPosition = Vector2.new(60, 60),
			},
			Elements = {},
		},
		Resize = {
			Class = "Resize",
			Id = self.Id .. ">Resize",
			Top = {
				Class = "Side",
				Id = self.Id .. ">Resize>Top",
				State = 0,
			},
			Bottom = {
				Class = "Side",
				Id = self.Id .. ">Resize>Bottom",
				State = 0,
			},
			Left = {
				Class = "Side",
				Id = self.Id .. ">Resize>Left",
				State = 0,
			},
			Right = {
				Class = "Side",
				Id = self.Id .. ">Resize>Right",
				State = 0,
			},
			BottomLeft = {
				Class = "Side",
				Id = self.Id .. ">Resize>BottomLeft",
				State = 0,
			},
			BottomRight = {
				Class = "Side",
				Id = self.Id .. ">Resize>BottomRight",
				State = 0,
			},
		},
	}

	return self
end

function Window:UpdateTitleColour()
	local title: Frame? = self.Window.Title.Instance

	if title ~= nil then
		local titleColour: Types.Colour4 = if self.Collapsed == true
			then Style.Colours.TitleBgCollapsed
			elseif ImGuiInternal.NavWindow == self then Style.Colours.TitleBgActive
			else Style.Colours.TitleBg

		title.BackgroundColor3 = titleColour.Colour
		title.Transparency = titleColour.Transparency
	end
end

function Window:UpdatePosition()
	local instance: Frame? = self.Window.Instance

	if instance ~= nil then
		instance.Position = UDim2.fromOffset(self.Position.X, self.Position.Y)
	end
end

function Window:UpdateSize()
	local minimumTitleSize: Vector2 = self.Window.Title.MinimumSize
	if self.Collapsed == true then
		self.Window.Instance.Size = UDim2.fromOffset(self.Size.X, minimumTitleSize.Y)
		return
	end

	local minimumMenubarSize: Vector2 = self.Window.Menubar.MinimumSize
	local minimumFrameSize: Vector2 = self.Window.Frame.MinimumSize

	local width: number = math.max(math.max(minimumTitleSize.X, minimumMenubarSize.X), minimumFrameSize.X)
	local height: number = minimumTitleSize.Y + minimumMenubarSize.Y + minimumFrameSize.Y

	self.MinimumSize = Vector2.new(width, height)

	if self.Size.X < width then
		self.Size = Vector2.new(width, self.Size.Y)
	end
	if self.Size.Y < height then
		self.Size = Vector2.new(self.Size.X, height)
	end

	self.Window.Instance.Size = UDim2.fromOffset(self.Size.X, self.Size.Y)
end

function Window:SetAllStates(state: Types.ButtonState)
	self.State = state
	self.Window.Title.Collapse.State = state
	self.Window.Title.Close.State = state
end

function Window:DrawWindow(stack: number?)
	local instance: Frame? = self.Window.Instance

	if (instance == nil) or (self.RedrawThisFrame == true) then
		if instance ~= nil then
			instance:Destroy()
		end
		if self.RedrawThisFrame == true then
			self:SetAllStates(0)
		end

		local window: Frame = Instance.new("Frame")
		window.Name = "window:" .. self.Name
		window.ZIndex = stack or self.FocusOrder
		window.Position = UDim2.fromOffset(self.Position.X, self.Position.Y)
		window.Size = UDim2.fromScale(1, 1)

		window.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		window.BackgroundTransparency = 1
		window.BorderColor3 = Color3.fromRGB(0, 0, 0)
		window.BorderSizePixel = 0

		local stroke: UIStroke = Instance.new("UIStroke")
		stroke.Name = "stroke"
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Style.Colours.Border.Colour
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
		stroke.Transparency = Style.Colours.Border.Transparency
		stroke.Parent = window

		if self.Window.Resize.Instance ~= nil then
			self.Window.Resize.Instance:Destroy()
		end
		if (self.Flags.NoResize == false) and (self.Collapsed == false) then
			local resize: Frame = Instance.new("Frame")
			resize.Name = "resize"
			resize.ZIndex = 2
			resize.AnchorPoint = Vector2.new(0.5, 0.5)
			resize.Position = UDim2.fromScale(0.5, 0.5)
			resize.Size = UDim2.new(1, 4, 1, 4)

			resize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			resize.BackgroundTransparency = 1
			resize.BorderColor3 = Color3.fromRGB(0, 0, 0)
			resize.BorderSizePixel = 0
			resize.ClipsDescendants = true

			local top: Frame = Instance.new("Frame")
			top.Name = "top"
			top.Position = UDim2.fromOffset(2, 0)
			top.Size = UDim2.new(1, -4, 0, 2)

			top.BackgroundColor3 = Style.Colours.SeparatorActive.Colour
			top.BackgroundTransparency = 1
			top.BorderColor3 = Color3.fromRGB(0, 0, 0)
			top.BorderSizePixel = 0

			top.Parent = resize

			local bottom: Frame = Instance.new("Frame")
			bottom.Name = "bottom"
			bottom.AnchorPoint = Vector2.new(0, 2)
			bottom.Position = UDim2.new(0, 1, 1, 0)
			bottom.Size = UDim2.new(1, -5, 0, 2)

			bottom.BackgroundColor3 = Style.Colours.SeparatorActive.Colour
			bottom.BackgroundTransparency = 1
			bottom.BorderColor3 = Color3.fromRGB(0, 0, 0)
			bottom.BorderSizePixel = 0

			bottom.Parent = resize

			local left = Instance.new("Frame")
			left.Name = "left"
			left.Position = UDim2.fromOffset(0, 2)
			left.Size = UDim2.new(0, 2, 1, -4)

			left.BackgroundColor3 = Style.Colours.SeparatorActive.Colour
			left.BackgroundTransparency = 1
			left.BorderColor3 = Color3.fromRGB(0, 0, 0)
			left.BorderSizePixel = 0

			left.Parent = resize

			local right = Instance.new("Frame")
			right.Name = "right"
			right.AnchorPoint = Vector2.new(1, 0)
			right.Position = UDim2.new(1, 0, 0, 2)
			right.Size = UDim2.new(0, 2, 1, -5)

			right.BackgroundColor3 = Style.Colours.SeparatorActive.Colour
			right.BackgroundTransparency = 1
			right.BorderColor3 = Color3.fromRGB(0, 0, 0)
			right.BorderSizePixel = 0

			right.Parent = resize

			local bottom_right = Instance.new("ImageLabel")
			bottom_right.Name = "bottom_right"
			bottom_right.AnchorPoint = Vector2.new(1, 1)
			bottom_right.Position = UDim2.new(1, -2, 1, -2)
			bottom_right.Size = UDim2.fromOffset(Style.Sizes.TextSize, Style.Sizes.TextSize)

			bottom_right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			bottom_right.BackgroundTransparency = 1
			bottom_right.BorderColor3 = Color3.fromRGB(0, 0, 0)
			bottom_right.BorderSizePixel = 0

			bottom_right.Image = "rbxassetid://11723377444"
			bottom_right.ImageColor3 = Style.Colours.ResizeGrip.Colour
			bottom_right.ImageTransparency = Style.Colours.ResizeGrip.Transparency

			bottom_right.Parent = resize

			local bottom_left = Instance.new("ImageLabel")
			bottom_left.Name = "bottom_left"
			bottom_left.AnchorPoint = Vector2.new(0, 1)
			bottom_left.Position = UDim2.new(0, 2, 1, -2)
			bottom_left.Size = UDim2.fromOffset(13, 13)
			bottom_left.Rotation = 90

			bottom_left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			bottom_left.BackgroundTransparency = 1
			bottom_left.BorderColor3 = Color3.fromRGB(0, 0, 0)
			bottom_left.BorderSizePixel = 0

			bottom_left.Image = "rbxassetid://11723377444"
			bottom_left.ImageColor3 = Style.Colours.ResizeGrip.Colour
			bottom_left.ImageTransparency = 1

			bottom_left.Parent = resize

			resize.Parent = window

			self.Window.Resize.Instance = resize
			self.Window.Resize.Top.Instance = top
			self.Window.Resize.Bottom.Instance = bottom
			self.Window.Resize.Left.Instance = left
			self.Window.Resize.Right.Instance = right
			self.Window.Resize.BottomLeft.Instance = bottom_left
			self.Window.Resize.BottomRight.Instance = bottom_right
		end

		window.Parent = ImGuiInternal.Viewport
		self.Window.Instance = window
	end
end

function Window:DrawTitle()
	local windowTitle: Types.WindowTitle = self.Window.Title
	local instance: Frame? = windowTitle.Instance
	local textCorrect: boolean = self.Name == windowTitle.Text
	local closeButtonCorrect: boolean = (self.Flags.NoClose ~= (windowTitle.Close.Instance ~= nil))
	local collapseButtonCorrect: boolean = self.Flags.NoCollapse ~= (windowTitle.Collapse.Instance ~= nil)

	if
		(instance == nil)
		or (textCorrect == false)
		or (closeButtonCorrect == false)
		or (collapseButtonCorrect == false)
		or (self.RedrawThisFrame == true)
	then
		if instance ~= nil then
			instance:Destroy()
		end

		if windowTitle.Collapse.Instance ~= nil then
			windowTitle.Collapse.Instance:Destroy()
		end
		if windowTitle.Close.Instance ~= nil then
			windowTitle.Close.Instance:Destroy()
		end
		if windowTitle.Instance ~= nil then
			windowTitle.Instance:Destroy()
		end
		windowTitle.Text = nil

		-- Calculate any constants which determine size or position.
		local textSize: Vector2 = Utility.CalculateTextSize(self.Name)
		local collapseWidth: number = self.Flags.NoCollapse == false and 15 + Style.Sizes.ItemInnerSpacing.X or 0
		local closeWidth: number = self.Flags.NoClose == false and 15 + Style.Sizes.ItemInnerSpacing.X or 0
		local minTitleWidth = collapseWidth + closeWidth + 2 * Style.Sizes.FramePadding.X + textSize.X

		windowTitle.MinimumSize = Vector2.new(minTitleWidth, Utility.DefaultFramePaddedHeight)
		self:UpdateSize()

		local title: Frame = Instance.new("Frame")
		title.Name = "title"
		title.Position = UDim2.fromScale(0, 0)
		title.Size = UDim2.new(1, 0, 0, Utility.DefaultFramePaddedHeight)

		local titleColor: Types.Colour4 = if self.Collapsed == true
			then Style.Colours.TitleBgCollapsed
			elseif ImGuiInternal.NavWindow == self then Style.Colours.TitleBgActive
			else Style.Colours.TitleBg

		title.BackgroundColor3 = titleColor.Colour
		title.Transparency = titleColor.Transparency
		title.BorderColor3 = COLOUR3_BLACK
		title.BorderSizePixel = 0

		title.ClipsDescendants = true

		local padding = Instance.new("UIPadding")
		padding.Name = "padding"
		padding.PaddingTop = UDim.new(0, Style.Sizes.FramePadding.Y)
		padding.PaddingBottom = UDim.new(0, Style.Sizes.FramePadding.Y)
		padding.PaddingLeft = UDim.new(0, Style.Sizes.FramePadding.X)
		padding.PaddingRight = UDim.new(0, Style.Sizes.FramePadding.X)
		padding.Parent = title

		local text: TextLabel = Instance.new("TextLabel")
		text.Name = "text"
		text.Position = UDim2.fromOffset(collapseWidth or 0, 0)
		text.Size = UDim2.new(1, -collapseWidth - closeWidth, 0, Style.Sizes.TextSize)

		text.BackgroundColor3 = COLOUR3_WHITE
		text.BackgroundTransparency = 1
		text.BorderColor3 = COLOUR3_BLACK
		text.BorderSizePixel = 0

		text.Text = self.Name
		text.FontFace = Style.Font
		text.TextColor3 = Style.Colours.Text.Colour
		text.TextSize = Style.Sizes.TextSize
		text.TextWrapped = false
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.Parent = title
		windowTitle.Text = self.Name

		if self.Flags.NoCollapse == false then
			local dropdown: ImageLabel = Instance.new("ImageLabel")
			dropdown.Name = "dropdown"
			dropdown.Position = UDim2.fromOffset(-1, -1)
			dropdown.Size = UDim2.fromOffset(15, 15)

			dropdown.BackgroundColor3 = COLOUR3_WHITE
			dropdown.BackgroundTransparency = 1
			dropdown.BorderColor3 = COLOUR3_BLACK
			dropdown.BorderSizePixel = 0

			dropdown.Image = "rbxassetid://4673889148"
			dropdown.ImageColor3 = Style.Colours.Button.Colour
			dropdown.ImageTransparency = 1

			local icon: ImageLabel = Instance.new("ImageLabel")
			icon.Name = "icon"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.new(0.5, 0, 0.5, 0)
			icon.Size = UDim2.fromScale(1, 1)
			icon.Rotation = (self.Collapsed == true) and -90 or 0

			icon.BackgroundColor3 = COLOUR3_WHITE
			icon.BackgroundTransparency = 1
			icon.BorderColor3 = COLOUR3_BLACK
			icon.BorderSizePixel = 0

			icon.Image = "rbxassetid://11523280019"
			icon.ImageColor3 = Style.Colours.Text.Colour
			icon.ImageTransparency = Style.Colours.Text.Transparency
			icon.Parent = dropdown

			dropdown.Parent = title
			windowTitle.Collapse.Instance = dropdown
		end

		if self.Flags.NoClose == false then
			local close: ImageLabel = Instance.new("ImageLabel")
			close.Name = "close"
			close.AnchorPoint = Vector2.new(1, 0)
			close.Position = UDim2.new(1, 1, 0, -1)
			close.Size = UDim2.fromOffset(15, 15)

			close.BackgroundColor3 = COLOUR3_WHITE
			close.BackgroundTransparency = 1
			close.BorderColor3 = COLOUR3_BLACK
			close.BorderSizePixel = 0

			close.Image = "rbxassetid://4673889148"
			close.ImageColor3 = Style.Colours.Button.Colour
			close.ImageTransparency = 1

			local icon = Instance.new("ImageLabel")
			icon.Name = "close"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.new(0.5, 0, 0.5, 0)
			icon.Size = UDim2.fromScale(1, 1)

			icon.BackgroundColor3 = COLOUR3_WHITE
			icon.BackgroundTransparency = 1
			icon.BorderColor3 = COLOUR3_BLACK
			icon.BorderSizePixel = 0

			icon.Image = "rbxassetid://11506648985"
			icon.ImageRectOffset = Vector2.new(284, 4)
			icon.ImageRectSize = Vector2.new(24, 24)
			icon.ImageColor3 = Style.Colours.Text.Colour
			icon.ImageTransparency = Style.Colours.Text.Transparency
			icon.Parent = close

			close.Parent = title
			windowTitle.Close.Instance = close
		end

		title.Parent = self.Window.Instance
		windowTitle.Instance = title
	end
end

function Window:DrawMenuBar()
	if (self.Window.Menubar.Instance == nil) or (self.RedrawThisFrame == true) then
		if self.Window.Menubar.Instance ~= nil then
			self.Window.Menubar.Instance:Destroy()
		end

		local height: number = Style.Sizes.TextSize + 2 * Style.Sizes.FramePadding.Y

		local menubar: Frame = Instance.new("Frame")
		menubar.Name = "menubar"
		menubar.Position = UDim2.fromOffset(0, self.Window.Title.MinimumSize.Y)
		menubar.Size = UDim2.new(1, 0, 0, height)

		menubar.BackgroundColor3 = Style.Colours.MenuBarBg.Colour
		menubar.BackgroundTransparency = Style.Colours.MenuBarBg.Transparency
		menubar.BorderColor3 = COLOUR3_BLACK
		menubar.BorderSizePixel = 0

		menubar.Parent = self.Window.Instance
		self.Window.Menubar.Instance = menubar
		self.Window.Menubar.MinimumSize = Vector2.new(0, height)
	end
end

function Window:DrawFrame()
	local instance: Frame? = self.Window.Frame.Instance

	if (instance == nil) or (self.RedrawThisFrame == true) then
		if instance ~= nil then
			instance:Destroy()
		end

		if self.Collapsed == true then
			return
		end

		local titleAndMenuBarSize: number = self.Window.Title.MinimumSize.Y + self.Window.Menubar.MinimumSize.Y

		local frame: Frame = Instance.new("Frame")
		frame.Name = "frame"
		frame.Position = UDim2.fromOffset(0, titleAndMenuBarSize)
		frame.Size = UDim2.new(1, 0, 1, -titleAndMenuBarSize)

		frame.BackgroundColor3 = Style.Colours.WindowBg.Colour
		frame.BackgroundTransparency = Style.Colours.WindowBg.Transparency
		frame.BorderColor3 = COLOUR3_BLACK
		frame.BorderSizePixel = 0

		frame.ClipsDescendants = true

		local padding: UIPadding = Instance.new("UIPadding")
		padding.Name = "padding"
		padding.PaddingTop = UDim.new(0, Style.Sizes.WindowPadding.Y)
		padding.PaddingBottom = UDim.new(0, Style.Sizes.WindowPadding.Y)
		padding.PaddingLeft = UDim.new(0, Style.Sizes.WindowPadding.X)
		padding.PaddingRight = UDim.new(0, Style.Sizes.WindowPadding.X)

		padding.Parent = frame

		frame.Parent = self.Window.Instance
		self.Window.Frame.Instance = frame
	end
end

function Window:Destroy()
	if self.Window.Instance ~= nil then
		self.Window.Instance:Destroy()
	end

	setmetatable(self, nil)
end

return Window
