local StarterPlayer = game:GetService("StarterPlayer")
local Style = require(script.Parent.Parent.Utility.Style)
local Types = require(script.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Utility.Utility)
local ImGuiInternal: Types.ImGuiInternal = require(script.Parent.Parent.ImGuiInternal)

local Window = {}
Window.__index = Window
Window.ClassName = "ImGuiWindow"

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
	self.Id = windowName

	self.ParentWindow = parentWindow or nil
	self.RootWindow = parentWindow and parentWindow.RootWindow or nil
	-- self.PopupRootWindow = nil
	-- self.ParentWindowFromStack = nil
	-- self.PopupParentRootWindow = nil
	self.ChildWindows = {}

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

	self.State = 0
	self.Active = true
	self.WasActive = true
	self.Appearing = false
	self.Collapsed = false
	self.Open = { true }

	self.RedrawThisFrame = false
	self.RedrawNextFrame = false

	self.DropdownId = Utility.GenerateRandomId()
	self.CloseId = Utility.GenerateRandomId()

	self.Window = {
		-- Instance = nil,
		Active = false,
		WasActive = false,
		Title = {
			Id = self.Id .. ">Title",
			-- Instance = nil,
			Text = "",
			Collapse = {
				Id = self.Id .. ">Title>Collapse",
				State = 0,
				PreviousState = 0,
			},
			Close = {
				Id = self.Id .. ">Title>Close",
				State = 0,
				PreviousState = 0,
			},
			MinimumSize = Vector2.new(0, 0),
		},
		Menubar = {
			-- Instance = nil,
			Menus = {},
			MinimumSize = Vector2.new(0, 0),
		},
		Frame = {
			-- Instance = nil,
			MinimumSize = Vector2.new(0, 0),
		},
	}

	return self
end

function Window:UpdateSize()
	local minimumTitleSize: Vector2 = self.Window.Title.MinimumSize
	if self.Collapsed == true then
		self.Window.Instance.Size = UDim2.fromOffset(minimumTitleSize.X, minimumTitleSize.Y)
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

		window.Parent = ImGuiInternal.Viewport
		self.Window.Instance = window
	end
end

function Window:DrawTitle()
	local instance: Frame? = self.Window.Title.Instance
	local textCorrect: boolean = self.Name == self.Window.Title.Text
	local closeButtonCorrect: boolean = (self.Flags.NoClose ~= (self.Window.Title.Close.Instance ~= nil))
	local collapseButtonCorrect: boolean = self.Flags.NoCollapse ~= (self.Window.Title.Collapse.Instance ~= nil)

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

		if self.Window.Title.Collapse.Instance ~= nil then
			self.Window.Title.Collapse.Instance:Destroy()
		end
		if self.Window.Title.Close.Instance ~= nil then
			self.Window.Title.Close.Instance:Destroy()
		end
		if self.Window.Title.Instance ~= nil then
			self.Window.Title.Instance:Destroy()
		end
		self.Window.Title.Text = nil

		-- Calculate any constants which determine size or position.
		local textSize: Vector2 = Utility.CalculateTextSize(self.Name)
		local collapseWidth: number = self.Flags.NoCollapse == false and 15 + Style.Sizes.ItemInnerSpacing.X or 0
		local closeWidth: number = self.Flags.NoClose == false and 15 + Style.Sizes.ItemInnerSpacing.X or 0
		local minTitleWidth = collapseWidth + closeWidth + 2 * Style.Sizes.FramePadding.X + textSize.X

		self.Window.Title.MinimumSize = Vector2.new(minTitleWidth, Utility.DefaultFramePaddedHeight)
		self:UpdateSize()

		-- build the instance
		local title: Frame = Instance.new("Frame")
		title.Name = "title"
		title.Position = UDim2.fromScale(0, 0)
		title.Size = UDim2.fromOffset(self.Size.X, Utility.DefaultFramePaddedHeight)

		title.BackgroundColor3 = (ImGuiInternal.ActiveWindow == self) and Style.Colours.TitleBgActive.Color
			or (self.Open[1] == true) and Style.Colours.TitleBg.Color
			or Style.Colours.TitleBgCollapsed.Color
		title.Transparency = (ImGuiInternal.ActiveWindow == self) and Style.Colours.TitleBgActive.Transparency
			or (self.Open[1] == true) and Style.Colours.TitleBg.Transparency
			or Style.Colours.TitleBgCollapsed.Transparency
		title.BorderColor3 = Color3.fromRGB(0, 0, 0)
		title.BorderSizePixel = 0

		local padding = Instance.new("UIPadding")
		padding.Name = "padding"
		padding.PaddingBottom = UDim.new(0, 3)
		padding.PaddingLeft = UDim.new(0, 4)
		padding.PaddingRight = UDim.new(0, 4)
		padding.PaddingTop = UDim.new(0, 3)
		padding.Parent = title

		local text: TextLabel = Instance.new("TextLabel")
		text.Name = "text"
		text.Position = UDim2.fromOffset(collapseWidth or 0, -1)
		text.Size = UDim2.new(1, -collapseWidth - closeWidth, 0, Style.Sizes.TextSize)

		text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		text.BackgroundTransparency = 1
		text.BorderColor3 = Color3.fromRGB(0, 0, 0)
		text.BorderSizePixel = 0

		text.Text = self.Name
		text.FontFace = Font.new("Arial")
		text.TextColor3 = Style.Colours.Text.Color
		text.TextSize = Style.Sizes.TextSize
		text.TextWrapped = false
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.Parent = title
		self.Window.Title.Text = self.Name

		if self.Flags.NoCollapse == false then
			local dropdown: ImageLabel = Instance.new("ImageLabel")
			dropdown.Name = "dropdown"
			dropdown.Position = UDim2.fromOffset(-1, -2)
			dropdown.Size = UDim2.fromOffset(15, 15)
			dropdown.Rotation = (self.Collapsed == true) and -90 or 0

			dropdown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			dropdown.BackgroundTransparency = 1
			dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
			dropdown.BorderSizePixel = 0

			dropdown.Image = "rbxassetid://4673889148"
			dropdown.ImageColor3 = Style.Colours.Button.Color
			dropdown.ImageTransparency = 1

			local icon: ImageLabel = Instance.new("ImageLabel")
			icon.Name = "icon"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.new(0.5, 0, 0.5, 1)
			icon.Size = UDim2.fromOffset(11, 9)

			icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			icon.BackgroundTransparency = 1
			icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
			icon.BorderSizePixel = 0

			icon.Image = "rbxassetid://1248849582"
			icon.ImageColor3 = Style.Colours.Text.Color
			icon.ImageTransparency = Style.Colours.Text.Transparency
			icon.Parent = dropdown

			dropdown.Parent = title
			self.Window.Title.Collapse.Instance = dropdown
		end

		if self.Flags.NoClose == false then
			local close: ImageLabel = Instance.new("ImageLabel")
			close.Name = "close"
			close.AnchorPoint = Vector2.new(1, 0)
			close.Position = UDim2.new(1, 1, 0, -2)
			close.Size = UDim2.fromOffset(15, 15)

			close.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			close.BackgroundTransparency = 1
			close.BorderColor3 = Color3.fromRGB(0, 0, 0)
			close.BorderSizePixel = 0

			close.Image = "rbxassetid://4673889148"
			close.ImageColor3 = Style.Colours.Button.Color
			close.ImageTransparency = 1

			local icon = Instance.new("ImageLabel")
			icon.Name = "close"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.new(0.5, 0, 0.5, 0)
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

			close.Parent = title
			self.Window.Title.Close.Instance = close
		end

		title.Parent = self.Window.Instance
		self.Window.Title.Instance = title
	end
end

function Window:Destroy()
	if self.Instance then
		self.Instance:Destroy()
	end

	setmetatable(self, nil)
end

return Window
