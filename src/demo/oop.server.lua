type ImGuiWindow = typeof(setmetatable(
	{} :: {
		Name: string,
		Class: "Window",
		Id: string | number,
		Hash: string | number?,

		ParentWindow: ImGuiWindow?,
		RootWindow: ImGuiWindow?,

		LastFrameActive: number,
		FocusOrder: number,
	},
	{} :: {
		__index: { [any]: any },
		ClassName: string,

		new: (windowName: string) -> (),

		UpdateTitleColour: (self: ImGuiWindow) -> (),
		UpdatePosition: (self: ImGuiWindow) -> (),
		UpdateSize: (self: ImGuiWindow) -> (),
		SetAllStates: (self: ImGuiWindow, state: number) -> (),
		Destroy: (self: ImGuiWindow) -> (),
	}
))

local Window = {}
Window.__index = Window
Window.ClassName = "Window"

function Window.new(windowName: string): (ImGuiWindow)
	local self: ImGuiWindow = setmetatable({
		Name = windowName,
		Id = windowName,
		Hash = windowName,
		Class = "ImGuiWindow",

		ParentWindow = nil,
		RootWindow = nil,

		LastFrameActive = -1,
		FocusOrder = 0,
	}, Window) :: ImGuiWindow

	return self
end

function Window:UpdateTitleColour() end

function Window:UpdatePosition() end

function Window:UpdateSize() end

function Window:SetAllStates(state: number) end

function Window:Destroy() end
