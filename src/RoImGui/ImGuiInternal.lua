local Types = require(script.Parent.Types)

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
	PreviousActiveId = 0,

	ActiveIdClickOffset = Vector2.zero,

	Viewport = Instance.new("ScreenGui"),

	ActiveWindow = nil,
	PreviousActiveWindow = nil,
	HoveredWindow = nil,
	MovingWindow = nil,
	CurrentWindow = nil,
	Windows = {},
	WindowStack = {},
	WindowOrder = {},
	WindowFocusOrder = {},

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
ImGuiInternal.Viewport.ZIndexBehavior = Enum.ZIndexBehavior.Global
ImGuiInternal.Viewport.IgnoreGuiInset = false
ImGuiInternal.Viewport.DisplayOrder = 100
ImGuiInternal.Viewport.Parent = playerGui

return ImGuiInternal
