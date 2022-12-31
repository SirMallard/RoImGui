local guiService: GuiService = game:GetService("GuiService")

local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Utility.Utility)
local Style = require(script.Parent.Utility.Style)

local userInputService: UserInputService = game:GetService("UserInputService")
local players: Players = game:GetService("Players")
local player: Player = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local playerGui: PlayerGui = player:WaitForChild("PlayerGui")

--[[
	CONSTANTS
]]
local MOUSE_DOUBLE_CLICK_TIME: number = 0.3 -- maximum interval between clicks
local MOUSE_DOUBLE_CLICK_MAGNITUDE: number = 6 -- maximum pixels moved for clicks

local ImGuiInternal: Types.ImGuiInternal = {
	Widgets = {},

	Stack = {},
	LastStack = {},

	Frame = -1,
	Time = 0,
	ElapsedTime = 0,
	GuiInset = Vector2.zero,

	HoverId = "",
	ActiveId = "",

	HoldOffset = Vector2.zero,

	-- ActiveWindow = nil,
	-- HoveredWindow = nil,
	-- MovingWindow = nil,
	-- CurrentWindow = nil,
	-- NavWindow = nil,
	-- ResizingWindow = nil,

	ResizeSize = Vector2.zero,

	Windows = {},
	WindowStack = {},
	WindowFocusOrder = {},

	ElementFrameStack = {},
	ChildWindowCount = 0,

	MouseButton1 = {
		Down = false,
		DownOnThisFrame = false,
		DownFrames = 0,
		DownTime = 0,

		Up = false,
		UpOnThisFrame = false,
		UpFrames = 0,
		UpTime = 0,

		LastClickFrame = 0,
		LastClickTime = 0,
		Clicks = 0,
	},
	MouseButton2 = {
		Down = false,
		DownOnThisFrame = false,
		DownFrames = 0,
		DownTime = 0,

		Up = false,
		UpOnThisFrame = false,
		UpFrames = 0,
		UpTime = 0,

		LastClickFrame = 0,
		LastClickTime = 0,
		Clicks = 0,
	},
	MouseCursor = {
		Position = Vector2.zero,
		Delta = Vector2.zero,
		Magnitude = 0,
	},
	ScreenSize = Vector2.zero,

	NextItemData = {
		Style = {
			Colours = {},
			Sizes = {},
		},
	},

	Debug = {},

	Status = "Stopped",
} :: Types.ImGuiInternal

function ImGuiInternal:Initialise()
	local viewport: ScreenGui = Instance.new("ScreenGui")
	viewport.Name = "RoImGui"
	viewport.ResetOnSpawn = false
	viewport.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	viewport.IgnoreGuiInset = false
	viewport.DisplayOrder = 100
	viewport.Parent = playerGui

	local debugElements: Frame = Instance.new("Frame")
	debugElements.Name = "debug_elements"
	debugElements.ZIndex = 5
	debugElements.AnchorPoint = Vector2.new(0.5, 0.5)
	debugElements.Position = UDim2.fromScale(0.5, 0.5)
	debugElements.Size = UDim2.fromScale(1, 1)

	debugElements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	debugElements.BackgroundTransparency = 1
	debugElements.BorderColor3 = Color3.fromRGB(0, 0, 0)
	debugElements.BorderSizePixel = 0

	debugElements.Parent = viewport

	local hoverELement: Frame = Instance.new("Frame")
	hoverELement.Name = "hover_element"
	hoverELement.ZIndex = 2

	hoverELement.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hoverELement.BackgroundTransparency = 1
	hoverELement.BorderColor3 = Color3.fromRGB(0, 0, 0)
	hoverELement.BorderSizePixel = 0

	hoverELement.Parent = debugElements

	local stroke: UIStroke = Instance.new("UIStroke")
	stroke.Name = "stroke"
	stroke.Thickness = 1
	stroke.Color = Style.Colours.DragDropTarget.Colour
	stroke.Transparency = Style.Colours.DragDropTarget.Transparency
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.Enabled = false

	stroke.Parent = hoverELement

	ImGuiInternal.Debug.HoverElement = hoverELement
	ImGuiInternal.Debug.HoverDebug = { false }
	ImGuiInternal.Viewport = viewport

	ImGuiInternal.Status = "Started"
	ImGuiInternal.GuiInset = guiService:GetGuiInset()
end

function UpdateMouseButton(mouseButtonData: Types.MouseButtonData, button: Enum.UserInputType)
	mouseButtonData.DownOnThisFrame = false
	mouseButtonData.UpOnThisFrame = false
	mouseButtonData.ClicksThisFrame = 0

	local mouse1Down: boolean = userInputService:IsMouseButtonPressed(button)
	if mouse1Down == true then
		mouseButtonData.DownFrames += 1 -- Down for at least 1 frame.
		mouseButtonData.DownTime += ImGuiInternal.DeltaTime

		if mouseButtonData.Down == false then
			mouseButtonData.DownOnThisFrame = true -- Not already marked as down, so must be first time.

			mouseButtonData.UpFrames = 0
			mouseButtonData.UpTime = 0
		end
	elseif mouse1Down == false then
		mouseButtonData.UpFrames += 1
		mouseButtonData.UpTime += ImGuiInternal.DeltaTime

		if mouseButtonData.Up == false then
			mouseButtonData.UpOnThisFrame = true -- Not already marked as up, so must be first time.

			mouseButtonData.Clicks += 1
			mouseButtonData.ClicksThisFrame = mouseButtonData.Clicks

			mouseButtonData.LastClickFrame = ImGuiInternal.Frame
			mouseButtonData.LastClickTime = ImGuiInternal.ElapsedTime

			mouseButtonData.DownFrames = 0 -- No need to write every frame.
			mouseButtonData.DownTime = 0
		end
	end

	if
		((ImGuiInternal.ElapsedTime - mouseButtonData.LastClickTime) > MOUSE_DOUBLE_CLICK_TIME)
		or (ImGuiInternal.MouseCursor.Magnitude > MOUSE_DOUBLE_CLICK_MAGNITUDE)
	then
		mouseButtonData.Clicks = 0
	end

	mouseButtonData.Down = mouse1Down
	mouseButtonData.Up = not mouse1Down
end

function ImGuiInternal:UpdateMouseInputs()
	-- Set up the data for the frame.
	self.ScreenSize = ImGuiInternal.Viewport.AbsoluteSize
	local position: Vector2 = userInputService:GetMouseLocation() - self.GuiInset
	position = Vector2.new(math.clamp(position.X, 0, self.ScreenSize.X), math.clamp(position.Y, 0, self.ScreenSize.Y))
	self.MouseCursor.Delta = position - self.MouseCursor.Position
	self.MouseCursor.Position = position
	self.MouseCursor.Magnitude = self.MouseCursor.Delta.Magnitude

	Utility.Update(self.MouseCursor.Position)

	UpdateMouseButton(self.MouseButton1, Enum.UserInputType.MouseButton1)
	UpdateMouseButton(self.MouseButton2, Enum.UserInputType.MouseButton2)
end

function ImGuiInternal:UpdateTime(deltaTime: number)
	self.Frame += 1
	self.Time = os.time()
	self.ElapsedTime += deltaTime
	self.DeltaTime = deltaTime
end

return ImGuiInternal
