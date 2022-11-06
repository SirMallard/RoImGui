local Types = require(script.Parent.Parent.Types)
local Color4 = require(script.Parent.Color4)

local ImGui_Style_Size: Types.ImGuiStyleSize = {
	WindowPadding = Vector2.new(8, 8),
	FramePadding = Vector2.new(4, 3),
	ItemSpacing = Vector2.new(8, 8),
	ItemInnerSpacing = Vector2.new(4, 4),
	CellPadding = Vector2.new(4, 2),

	IndentSpacing = 21,
	ScrollbarSize = 14,
	GrabMinSize = 12,

	TextMinHeight = 12,
	TextSize = 13, -- best size we can use because size 12 fonts doesn't match
}

local ImGui_Style_Colours: Types.ImGuiStyleColour = {} :: Types.ImGuiStyleColour

ImGui_Style_Colours.Text = Color4.new(1.0, 1.0, 1.0, 0.0)
ImGui_Style_Colours.TextDisabled = Color4.new(0.5, 0.5, 0.5, 0.0)
ImGui_Style_Colours.WindowBg = Color4.new(0.06, 0.06, 0.06, 0.06)
ImGui_Style_Colours.ChildBg = Color4.new(0.0, 0.0, 0.0, 1.0)
ImGui_Style_Colours.PopupBg = Color4.new(0.08, 0.08, 0.08, 0.06)
ImGui_Style_Colours.Border = Color4.new(0.43, 0.43, 0.5, 0.5)
ImGui_Style_Colours.BorderShadow = Color4.new(0.0, 0.0, 0.0, 1.0)
ImGui_Style_Colours.FrameBg = Color4.new(0.16, 0.29, 0.48, 0.46)
ImGui_Style_Colours.FrameBgHovered = Color4.new(0.26, 0.59, 0.98, 0.6)
ImGui_Style_Colours.FrameBgActive = Color4.new(0.26, 0.59, 0.98, 0.33)
ImGui_Style_Colours.TitleBg = Color4.new(0.04, 0.04, 0.04, 0.0)
ImGui_Style_Colours.TitleBgActive = Color4.new(0.16, 0.29, 0.48, 0.0)
ImGui_Style_Colours.TitleBgCollapsed = Color4.new(0.0, 0.0, 0.0, 0.49)
ImGui_Style_Colours.MenuBarBg = Color4.new(0.14, 0.14, 0.14, 0.0)
ImGui_Style_Colours.ScrollbarBg = Color4.new(0.02, 0.02, 0.02, 0.47)
ImGui_Style_Colours.ScrollbarGrab = Color4.new(0.31, 0.31, 0.31, 0.0)
ImGui_Style_Colours.ScrollbarGrabHovered = Color4.new(0.41, 0.41, 0.41, 0.0)
ImGui_Style_Colours.ScrollbarGrabActive = Color4.new(0.51, 0.51, 0.51, 0.0)
ImGui_Style_Colours.CheckMark = Color4.new(0.26, 0.59, 0.98, 0.0)
ImGui_Style_Colours.SliderGrab = Color4.new(0.24, 0.52, 0.88, 0.0)
ImGui_Style_Colours.SliderGrabActive = Color4.new(0.26, 0.59, 0.98, 0.0)
ImGui_Style_Colours.Button = Color4.new(0.26, 0.59, 0.98, 0.6)
ImGui_Style_Colours.ButtonHovered = Color4.new(0.26, 0.59, 0.98, 0.0)
ImGui_Style_Colours.ButtonActive = Color4.new(0.06, 0.53, 0.98, 0.0)
ImGui_Style_Colours.Header = Color4.new(0.26, 0.59, 0.98, 0.69)
ImGui_Style_Colours.HeaderHovered = Color4.new(0.26, 0.59, 0.98, 0.2)
ImGui_Style_Colours.HeaderActive = Color4.new(0.26, 0.59, 0.98, 0.0)
ImGui_Style_Colours.Separator = Color4.new(0.43, 0.43, 0.50, 0.5)
ImGui_Style_Colours.SeparatorHovered = Color4.new(0.1, 0.4, 0.75, 0.22)
ImGui_Style_Colours.SeparatorActive = Color4.new(0.1, 0.4, 0.75, 0.0)
ImGui_Style_Colours.ResizeGrip = Color4.new(0.26, 0.59, 0.98, 0.8)
ImGui_Style_Colours.ResizeGripHovered = Color4.new(0.26, 0.59, 0.98, 0.33)
ImGui_Style_Colours.ResizeGripActive = Color4.new(0.26, 0.59, 0.98, 0.05)
ImGui_Style_Colours.PlotLines = Color4.new(0.61, 0.61, 0.61, 0.0)
ImGui_Style_Colours.PlotLinesHovered = Color4.new(1.0, 0.43, 0.35, 0.0)
ImGui_Style_Colours.PlotHistogram = Color4.new(0.9, 0.7, 0.0, 0.0)
ImGui_Style_Colours.PlotHistogramHovered = Color4.new(1.0, 0.6, 0.0, 0.0)
ImGui_Style_Colours.TableHeaderBg = Color4.new(0.19, 0.19, 0.2, 0.0)
ImGui_Style_Colours.TableBorderStrong = Color4.new(0.31, 0.31, 0.35, 0.0)
ImGui_Style_Colours.TableRowBgAlt = Color4.new(1.0, 1.0, 1.0, 0.94)
ImGui_Style_Colours.TextSelectedBg = Color4.new(0.26, 0.59, 0.98, 0.65)
ImGui_Style_Colours.DragDropTarget = Color4.new(1.0, 1.0, 0.0, 0.1)
ImGui_Style_Colours.NavHighlight = Color4.new(0.26, 0.59, 0.98, 0.0)
ImGui_Style_Colours.NavWindowingHighlight = Color4.new(1.0, 1.0, 1.0, 0.3)
ImGui_Style_Colours.NavWindowingDimBg = Color4.new(0.8, 0.8, 0.8, 0.8)
ImGui_Style_Colours.ModalWindowDimBg = Color4.new(0.8, 0.8, 0.8, 0.65)

ImGui_Style_Colours.Transparent = Color4.new(1, 1, 1, 1)

ImGui_Style_Colours.Tab = ImGui_Style_Colours.Header:Lerp(ImGui_Style_Colours.TitleBgActive, 0.8)
ImGui_Style_Colours.TabHovered = ImGui_Style_Colours.HeaderHovered
ImGui_Style_Colours.TabActive = ImGui_Style_Colours.HeaderActive:Lerp(ImGui_Style_Colours.TitleBgActive, 0.6)
ImGui_Style_Colours.TabUnfocused = ImGui_Style_Colours.Tab:Lerp(ImGui_Style_Colours.TitleBg, 0.8)
ImGui_Style_Colours.TabUnfocusedActive = ImGui_Style_Colours.TabActive:Lerp(ImGui_Style_Colours.TitleBg, 0.4)

return {
	Sizes = ImGui_Style_Size,
	Colours = ImGui_Style_Colours,
	Font = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
}
