local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Flags = require(script.Parent.Parent.Utility.Flags).WindowFlags
local Utility = require(script.Parent.Parent.Utility.Utility)
local Internal = require(script.Parent.Parent.Internal)

local Window = {
	Class = "Window",
}

function Window.new(flags, id: Types.Id, name: string, open: Types.BooleanVariable?)
	local self = {} :: Types.Window

	self.Id = id
	self.Flags = flags

	self.Name = name

	self.Frame = 0
	self.SkipElements = false
	self.RedrawFrame = -1

	self.DrawCursor = {
		Position = Vector2.zero,
		PreviousPosition = Vector2.zero,
		MaximumPosition = Vector2.zero,
		LineHeight = 0,
		TextLineOffset = 0,
		Indent = 0,
		SameLine = false,
	}

	self.Elements = {}

	self.Properties = {
		Collapsed = false,
		CanClose = open ~= nil,
		Position = Vector2.zero,
		Size = Vector2.zero,
		ScrollPosition = Vector2.zero,
		MinimumSize = Vector2.zero,

		CloseState = 0,
		CollapseState = 0,
	}

	self.Values = {
		Open = open and open[1][open[2]] or { true },
		_open = open and open[1][open[2]] or true,
		Key = open and open[2] or 1,
	}

	return setmetatable(self, Window)
end

function Window:Draw()
	local window = Instance.new("Frame")
	window.Name = `window:{self.Name}`
	window.Position = UDim2.fromOffset(self.Properties.Position.X, self.Properties.Position.Y)
	window.Size = UDim2.fromOffset(self.Properties.Size.X, self.Properties.Size.Y)

	if bit32.band(self.Flags, Flags.NoBackground) then
		Utility.applyStyle(window, Style.Colours.Transparent)
	else
		Utility.applyStyle(window, Style.Colours.WindowBg)
	end

	local stroke: UIStroke = Instance.new("UIStroke")
	stroke.Name = "stroke"
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Style.Colours.Border.Colour
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.Transparency = Style.Colours.Border.Transparency
	stroke.Parent = window

	-- only draw if we have a titlebar
	if not bit32.band(self.Flags, Flags.NoTitleBar) then
		local title = self:DrawTitle()
		title.Parent = window
	end

	self.Instance = window
end

function Window:DrawTitle()
	local textBounds: Vector2 = Utility.getTextSize(self.Name)
	local textLeftPadding: number = Style.Sizes.FramePadding.X
	local textRightPadding: number = Style.Sizes.FramePadding.X
	if self.Properties.CanClose then
		textRightPadding += Style.Sizes.TextSize + Style.Sizes.ItemInnerSpacing.X
	end
	if not bit32.band(self.Flags, Flags.NoCollapse) then
		textLeftPadding += Style.Sizes.TextSize + Style.Sizes.ItemInnerSpacing.X
	end

	local title: Frame = Instance.new("Frame")
	title.Name = "title"
	title.Position = UDim2.fromOffset(0, 0)
	title.Size = UDim2.new(1, 0, 0, Style.Sizes.TextMinHeight + 2 * Style.Sizes.FramePadding.Y)
	title.ClipsDescendants = true
	Utility.applyStyle(
		title,
		Style.ButtonStyles[if self.Properties.Collapsed
			then 4
			elseif Internal.FrameData.WindowData.Active.Id == self.Id then 2
			else 1]
	)

	Utility.newPadding(Style.Sizes.FramePadding).Parent = title

	-- the title text is placed within another frame which allows for movement side to side.
	local titleFrame: Frame = Instance.new("Frame")
	titleFrame.Name = "window_title"
	titleFrame.AnchorPoint = Vector2.new(0, 0.5)
	titleFrame.Position = UDim2.new(1, textLeftPadding, 0.5, 0)
	titleFrame.Size = UDim2.new(1, -textLeftPadding - textRightPadding, 1, 0)
	Utility.applyStyle(titleFrame, Style.Colours.Transparent)
	titleFrame.Parent = title

	local text: TextLabel = Instance.new("TextLabel")
	text.Name = "text"
	text.AnchorPoint = Vector2.new(Style.Sizes.TitleAlign, 0.5)
	text.Position = UDim2.fromScale(Style.Sizes.TitleAlign, 0.5)
	text.Size = UDim2.fromOffset(textBounds.X, Style.Sizes.TextSize)

	text.Text = self.Name
	Utility.applyStyle(text)
	Utility.applyText(text)
	text.Parent = titleFrame

	-- if the window has a close boolean value passed
	if self.Properties.CanClose then
		local closeButton: Frame = Instance.new("Frame")
		closeButton.Name = "close"
		closeButton.AnchorPoint = Vector2.new(1, 0.5)
		closeButton.Position = UDim2.new(1, 1, 0.5, -1)
		closeButton.Size = UDim2.fromOffset(Style.Sizes.TextSize + 2, Style.Sizes.TextSize + 2)
		Utility.applyStyle(closeButton, Style.ButtonStyles.TitleButton[self.Properties.CloseState])
		closeButton.Parent = titleFrame

		local cross: ImageLabel = Instance.new("ImageLabel")
		cross.Name = "cross"
		cross.AnchorPoint = Vector2.new(0.5, 0.5)
		cross.Position = UDim2.fromScale(0.5, 0.5)
		cross.Size = UDim2.fromOffset(Style.Sizes.TextSize, Style.Sizes.TextSize)
		cross.Image = Style.Images.Cross
		Utility.applyStyle(cross)
		Utility.applyImageStyle(cross, Style.Colours.Text)
		cross.Parent = closeButton
	end

	-- if the flags allow for collapsing
	if not bit32.band(self.Flags, Flags.NoCollapse) then
		local collapseButton: Frame = Instance.new("Frame")
		collapseButton.Name = "close"
		collapseButton.AnchorPoint = Vector2.new(0, 0.5)
		collapseButton.Position = UDim2.new(0, -1, 0.5, -1)
		collapseButton.Size = UDim2.fromOffset(Style.Sizes.TextSize + 2, Style.Sizes.TextSize + 2)
		Utility.applyStyle(collapseButton, Style.ButtonStyles.TitleButton[self.Properties.CollapseState])
		collapseButton.Parent = titleFrame

		local arrow: ImageLabel = Instance.new("ImageLabel")
		arrow.Name = "arrow"
		arrow.AnchorPoint = Vector2.new(0.5, 0.5)
		arrow.Position = UDim2.fromScale(0.5, 0.5)
		arrow.Size = UDim2.fromOffset(Style.Sizes.TextSize, Style.Sizes.TextSize)
		arrow.Image = Style.Images.Dropdown
		Utility.applyStyle(arrow)
		Utility.applyStyle(arrow, Style.Colours.Text)
		arrow.Parent = collapseButton
	end

	return title
end

function Window:DrawFrame() end

--[[
	every frame we need to update:
		handled elsewhere:
			update the position
			update the size
		in the window:
			flags - entire
			title bar colour - style the frame
			collapsed - redraw
			closed - wedraw entirely
			global style - redraw entire
			
]]
function Window:Update(flags: Types.Flags, open: Types.BooleanVariable)
	if self.Flags ~= flags then
		self.RedrawFrame = Internal.FrameData.Frame
	end

	open = open

	if (self.RedrawFrame == Internal.FrameData.Frame) or Internal.ElementData.RedrawElement then
		self:Draw()
	end
end

return Window
