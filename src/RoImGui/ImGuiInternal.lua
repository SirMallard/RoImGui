local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Utility.Utility)

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
	ElapsedTime = 0,
	GuiInset = Vector2.zero,

	HoverId = 0,
	ActiveId = 0,

	HoldOffset = Vector2.zero,

	Viewport = Instance.new("ScreenGui"),

	-- ActiveWindow = nil,
	-- HoveredWindow = nil,
	-- MovingWindow = nil,
	-- CurrentWindow = nil,
	-- NavWindow = nil,

	Windows = {},
	WindowStack = {},
	WindowFocusOrder = {},

	NextWindowData = {},

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

	Status = "Stopped",
} :: Types.ImGuiInternal

ImGuiInternal.Viewport.Name = "RoImGui"
ImGuiInternal.Viewport.ResetOnSpawn = false
ImGuiInternal.Viewport.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ImGuiInternal.Viewport.IgnoreGuiInset = false
ImGuiInternal.Viewport.DisplayOrder = 100
ImGuiInternal.Viewport.Parent = playerGui

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
	local position: Vector2 = userInputService:GetMouseLocation() - self.GuiInset
	self.MouseCursor.Delta = position - self.MouseCursor.Position
	self.MouseCursor.Position = position
	self.MouseCursor.Magnitude = self.MouseCursor.Delta.Magnitude

	Utility.Update(self.MouseCursor.Position)

	UpdateMouseButton(self.MouseButton1, Enum.UserInputType.MouseButton1)
	UpdateMouseButton(self.MouseButton2, Enum.UserInputType.MouseButton2)
end

function ImGuiInternal:UpdateTime(deltaTime: number)
	self.Frame += 1
	self.ElapsedTime += deltaTime
	self.DeltaTime = deltaTime
end

return ImGuiInternal
