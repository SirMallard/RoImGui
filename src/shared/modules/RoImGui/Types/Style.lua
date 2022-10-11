local Types = require(script.Parent.Types)
local Color4 = require(script.Parent.Color4)

local ImGui_Style_Size: Types.ImGuiType_Style_Size = {
	WindowPadding = Vector2.new(8, 8),
	FramePadding = Vector2.new(4, 3),
	ItemSpacing = Vector2.new(8, 8),
	ItemInnerSpacing = Vector2.new(4, 4),
	CellPadding = Vector2.new(4, 2),

	IndentSpacing = 21,
	ScrollbarSize = 14,
	GrabMinSize = 12,

	TextMinHeight = 12,
	TextSize = 13,
}

local ImGui_Style_Colours: Types.ImGuiType_Style_Colour = {
	Text = Color4.new(1.0, 1.0, 1.0, 0.0),
	TextDisabled = Color4.new(0.5, 0.5, 0.5, 0.0),
	WindowBg = Color4.new(0.06, 0.06, 0.06, 0.06),
	ChildBg = Color4.new(0.0, 0.0, 0.0, 1.0),
	PopupBg = Color4.new(0.08, 0.08, 0.08, 0.06),
	Border = Color4.new(0.43, 0.43, 0.5, 0.5),
	BorderShadow = Color4.new(0.0, 0.0, 0.0, 1.0),
	FrameBg = Color4.new(0.16, 0.29, 0.48, 0.46),
	FrameBgHovered = Color4.new(0.26, 0.59, 0.98, 0.6),
	FrameBgActive = Color4.new(0.26, 0.59, 0.98, 0.33),
	TitleBg = Color4.new(0.04, 0.04, 0.04, 0.0),
	TitleBgActive = Color4.new(0.16, 0.29, 0.48, 0.0),
	TitleBgCollapsed = Color4.new(0.0, 0.0, 0.0, 0.49),
	MenuBarBg = Color4.new(0.14, 0.14, 0.14, 0.0),
	ScrollbarBg = Color4.new(0.02, 0.02, 0.02, 0.47),
	ScrollbarGrab = Color4.new(0.31, 0.31, 0.31, 0.0),
	ScrollbarGrabHovered = Color4.new(0.41, 0.41, 0.41, 0.0),
	ScrollbarGrabActive = Color4.new(0.51, 0.51, 0.51, 0.0),
	CheckMark = Color4.new(0.26, 0.59, 0.98, 0.0),
	SliderGrab = Color4.new(0.24, 0.52, 0.88, 0.0),
	SliderGrabActive = Color4.new(0.26, 0.59, 0.98, 0.0),
	Button = Color4.new(0.26, 0.59, 0.98, 0.6),
	ButtonHovered = Color4.new(0.26, 0.59, 0.98, 0.0),
	ButtonActive = Color4.new(0.06, 0.53, 0.98, 0.0),
	Header = Color4.new(0.26, 0.59, 0.98, 0.69),
	HeaderHovered = Color4.new(0.26, 0.59, 0.98, 0.2),
	HeaderActive = Color4.new(0.26, 0.59, 0.98, 0.0),
	Separator = Color4.new(0.43, 0.43, 0.50, 0.5),
	SeparatorHovered = Color4.new(0.1, 0.4, 0.75, 0.22),
	SeparatorActive = Color4.new(0.1, 0.4, 0.75, 0.0),
	ResizeGrip = Color4.new(0.26, 0.59, 0.98, 0.8),
	ResizeGripHovered = Color4.new(0.26, 0.59, 0.98, 0.33),
	ResizeGripActive = Color4.new(0.26, 0.59, 0.98, 0.05),
	PlotLines = Color4.new(0.61, 0.61, 0.61, 0.0),
	PlotLinesHovered = Color4.new(1.0, 0.43, 0.35, 0.0),
	PlotHistogram = Color4.new(0.9, 0.7, 0.0, 0.0),
	PlotHistogramHovered = Color4.new(1.0, 0.6, 0.0, 0.0),
	TableHeaderBg = Color4.new(0.19, 0.19, 0.2, 0.0),
	TableBorderStrong = Color4.new(0.31, 0.31, 0.35, 0.0),
	TableRowBgAlt = Color4.new(1.0, 1.0, 1.0, 0.94),
	TextSelectedBg = Color4.new(0.26, 0.59, 0.98, 0.65),
	DragDropTarget = Color4.new(1.0, 1.0, 0.0, 0.1),
	NavHighlight = Color4.new(0.26, 0.59, 0.98, 0.0),
	NavWindowingHighlight = Color4.new(1.0, 1.0, 1.0, 0.3),
	NavWindowingDimBg = Color4.new(0.8, 0.8, 0.8, 0.8),
	ModalWindowDimBg = Color4.new(0.8, 0.8, 0.8, 0.65),

	Transparent = Color4.new(1, 1, 1, 1),
}

ImGui_Style_Colours["Tab"] = ImGui_Style_Colours.Header:Lerp(ImGui_Style_Colours.TitleBgActive, 0.8)
ImGui_Style_Colours["TabHovered"] = ImGui_Style_Colours.HeaderHovered
ImGui_Style_Colours["TabActive"] = ImGui_Style_Colours.HeaderActive:Lerp(ImGui_Style_Colours.TitleBgActive, 0.6)
ImGui_Style_Colours["TabUnfocused"] = ImGui_Style_Colours.Tab:Lerp(ImGui_Style_Colours.TitleBg, 0.8)
ImGui_Style_Colours["TabUnfocusedActive"] = ImGui_Style_Colours.TabActive:Lerp(ImGui_Style_Colours.TitleBg, 0.4)

return {
	Sizes = ImGui_Style_Size,
	Colours = ImGui_Style_Colours,
}
