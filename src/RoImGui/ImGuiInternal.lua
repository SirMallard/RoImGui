local Types = require(script.Parent.Types)
local Utility = require(script.Parent.Utility.Utility)

local userInputService: UserInputService = game:GetService("UserInputService")
local players: Players = game:GetService("Players")
local player: Player = players.LocalPlayer or players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local playerGui: PlayerGui = player:WaitForChild("PlayerGui")

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
		Up = false,
		UpOnThisFrame = false,
		UpFrames = 0,
		DownId = nil,
		UpId = nil,
	},
	MouseButton2 = {
		Down = false,
		DownOnThisFrame = false,
		DownFrames = 0,
		Up = false,
		UpOnThisFrame = false,
		UpFrames = 0,
		DownId = nil,
		UpId = nil,
	},
	MouseCursor = {
		MousePosition = Vector2.zero,
		MouseDelta = Vector2.zero,
	},

	Status = "Stopped",
} :: Types.ImGuiInternal

ImGuiInternal.Viewport.Name = "RoImGui"
ImGuiInternal.Viewport.ResetOnSpawn = false
ImGuiInternal.Viewport.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ImGuiInternal.Viewport.IgnoreGuiInset = false
ImGuiInternal.Viewport.DisplayOrder = 100
ImGuiInternal.Viewport.Parent = playerGui

function ImGuiInternal:UpdateMouseInputs()
	self.MouseButton1.DownOnThisFrame = false
	self.MouseButton1.UpOnThisFrame = false
	-- Set up the data for the frame.

	local position: Vector2 = userInputService:GetMouseLocation() - self.GuiInset
	self.MouseCursor.MouseDelta = position - self.MouseCursor.MousePosition
	self.MouseCursor.MousePosition = position

	Utility.Update(self.MouseCursor.MousePosition)

	local mouse1Down: boolean = userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	if mouse1Down == true then
		self.MouseButton1.DownFrames += 1 -- Down for at least 1 frame.
		if self.MouseButton1.Down == false then
			self.MouseButton1.DownOnThisFrame = true -- Not already marked as down, so must be first time.
		end
	elseif mouse1Down == false then
		if self.MouseButton1.Up == false then
			self.MouseButton1.UpOnThisFrame = true -- Not already marked as up, so must be first time.
			self.MouseButton1.DownFrames = 0 -- No need to write every frame.
		end
	end

	self.MouseButton1.Down = mouse1Down
	self.MouseButton1.Up = not mouse1Down

	local mouse2Down: boolean = userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	if mouse2Down == true then
		self.MouseButton2.DownFrames += 1 -- Down for at least 1 frame.
		if self.MouseButton2.Down == false then
			self.MouseButton2.DownOnThisFrame = true -- Not already marked as down, so must be first time.
		end
	elseif mouse2Down == false then
		if self.MouseButton2.Up == false then
			self.MouseButton2.UpOnThisFrame = true -- Not already marked as up, so must be first time.
			self.MouseButton2.DownFrames = 0 -- No need to write every frame.
		end
	end

	self.MouseButton2.Down = mouse2Down
	self.MouseButton2.Up = not mouse2Down
end

return ImGuiInternal
