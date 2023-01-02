local Style = require(script.Parent.Parent.Utility.Style)
local Types = require(script.Parent.Parent.Types)
local Utility = require(script.Parent.Parent.Utility.Utility)
local ImGuiInternal: Types.ImGuiInternal = require(script.Parent.Parent.ImGuiInternal)

local Popup = {}
Popup.__index = Popup
Popup.ClassName = "ImGuiPopup"

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

function Popup.new(popupName: string, parentWindow: Types.ImGuiWindow, flags: Types.PopupFlags): ()
	local self = setmetatable({}, Popup)

	self.Class = "Window"
	self.Id = parentWindow.Id .. ">Popups>" .. popupName
	self.Name = popupName

	self.ParentWindow = parentWindow
	self.RootWindow = parentWindow and parentWindow.RootWindow or parentWindow
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

	self.RedrawThisFrame = false -- DO NOT SET, changed internally based on .RedrawNextFrame
	self.RedrawNextFrame = false -- Calls a complete redraw for the next frame. Everything gets wiped. Used when

	self.Window = {
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
	}

	return self
end

function Popup:UpdatePosition()
	local instance: Frame? = self.Window.Instance

	if instance ~= nil then
		instance.Position = UDim2.fromOffset(self.Position.X, self.Position.Y)
	end
end

function Popup:UpdateSize()
	self.Window.Instance.Size = UDim2.fromOffset(self.Size.X, self.Size.Y)
end

function Popup:DrawWindow(stack: number?)
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

		window.Parent = ImGuiInternal.Viewport
		self.Window.Instance = window
	end
end

function Popup:DrawFrame()
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

function Popup:Destroy()
	if self.Window.Instance ~= nil then
		self.Window.Instance:Destroy()
	end

	setmetatable(self, nil)
end

return Popup
