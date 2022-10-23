local Types = require(script.Parent.Types)

local ImGuiInternal: Types.ImGuiInternal = {
	Widgets = {},

	Stack = {},
	LastStack = {},

	Frame = -1,
	ElapsedTime = 0,

	HoverId = 0,
	Hover = nil,
	ActiveId = 0,
	Active = nil,

	ActiveIdClickOffset = Vector2.zero,

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
