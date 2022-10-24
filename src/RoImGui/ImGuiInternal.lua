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

	HoverId = 0,
	ActiveId = 0,

	ActiveIdClickOffset = Vector2.zero,

	Viewport = Instance.new("ScreenGui"),

	ActiveWindow = nil,
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
ImGuiInternal.Viewport.DisplayOrder = 100
ImGuiInternal.Viewport.Parent = playerGui

function ImGuiInternal:RemoveHoverId(id: string)
	if ImGuiInternal.HoverId ~= id then
		return
	end

	ImGuiInternal.HoverId = nil
	ImGuiInternal.Hover = nil
end

function ImGuiInternal:SetHoverId(id: string, instance: Instance?)
	ImGuiInternal.HoverId = id
	ImGuiInternal.Hover = instance
end

function ImGuiInternal:IsHovering(id: string)
	if (ImGuiInternal.ActiveId ~= 0) and (ImGuiInternal.ActiveId ~= id) then
		return false
	end

	ImGuiInternal:SetHoverId(id)

	return true
end

function ImGuiInternal:IsActive(id: string)
	if ImGuiInternal.ActiveId then
		return
	end

	id = id
end

return ImGuiInternal
