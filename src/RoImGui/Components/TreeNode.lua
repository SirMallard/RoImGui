local Types = require(script.Parent.Parent.Types)
local Style = require(script.Parent.Parent.Utility.Style)
local Utility = require(script.Parent.Parent.Utility.Utility)

local TreeNode = {}
TreeNode.__index = TreeNode
TreeNode.ClassName = "TreeNode"

local COLOUR3_WHITE: Color3 = Color3.fromRGB(255, 255, 255)
local COLOUR3_BLACK: Color3 = Color3.fromRGB(0, 0, 0)

function TreeNode.new(text: string, value: { boolean }, window: Types.ImGuiWindow, elementFrame: Types.ElementFrame)
	local self = setmetatable({}, TreeNode)

	self.Text = text
	self.Class = "TreeNode"
	self.Id = elementFrame.Id .. ">" .. self.Text
	self.Value = value
	self.InternalValue = value[1]

	self.State = 0

	self.ElementFrame = elementFrame
	self.Window = window

	self.Active = false
	self.LastFrameActive = 0

	self.Size = Vector2.zero

	return self
end

function TreeNode:DrawTreeNode(position: Vector2)
	if self.Instance ~= nil then
		self.Instance:Destroy()
		self.Instance = nil
	end

	if self.ElementFrame.Instance == nil then
		return
	end

	local textSize: Vector2 = Utility.CalculateTextSize(self.Text)

	local treenode: Frame = Instance.new("Frame")
	treenode.Name = self.Text
	treenode.Position = UDim2.fromOffset(position.X, position.Y)
	treenode.Size = UDim2.new(1, -position.X, 0, Style.Sizes.TextSize)

	treenode.BackgroundColor3 = Style.Colours.Transparent.Colour
	treenode.BackgroundTransparency = Style.Colours.Transparent.Transparency
	treenode.BorderColor3 = COLOUR3_BLACK
	treenode.BorderSizePixel = 0

	local text: TextLabel = Instance.new("TextLabel")
	text.Name = "text"
	text.Position = UDim2.fromOffset(Style.Sizes.TextSize + 2 * Style.Sizes.FramePadding, 0)
	text.Size = UDim2.fromOffset(textSize.X, Style.Sizes.TextSize)

	text.BackgroundColor3 = COLOUR3_WHITE
	text.BackgroundTransparency = 1
	text.BorderColor3 = COLOUR3_BLACK
	text.BorderSizePixel = 0

	text.Text = self.Text
	text.FontFace = Style.Font
	text.TextColor3 = Style.Colours.Text.Colour
	text.TextTransparency = Style.Colours.Text.Transparency
	text.TextSize = Style.Sizes.TextSize
	text.TextWrapped = false

	text.Parent = treenode

	local dropdown: ImageLabel = Instance.new("ImageLabel")
	dropdown.Name = "dropdown"
	dropdown.Position = UDim2.fromOffset(Style.Sizes.FramePadding.X, 0)
	dropdown.Size = UDim2.fromOffset(Style.Sizes.TextSize, Style.Sizes.TextSize)
	dropdown.Rotation = (self.Value[1] == true) and 0 or -90

	dropdown.BackgroundColor3 = COLOUR3_WHITE
	dropdown.BackgroundTransparency = 1
	dropdown.BorderColor3 = COLOUR3_BLACK
	dropdown.BorderSizePixel = 0

	dropdown.Image = Style.Images.Dropdown
	dropdown.ImageColor3 = Style.Colours.Text.Colour
	dropdown.ImageTransparency = Style.Colours.Text.Transparency

	dropdown.Parent = treenode

	treenode.Parent = self.ElementFrame.Instance
	self.Instance = treenode
	self.Size = Vector2.new(textSize.X + 2 * Style.Sizes.FramePadding.X + Style.Sizes.TextSize, Style.Sizes.TextSize)
end

function TreeNode:UpdatePosition(position: Vector2)
	if self.Instance == nil then
		self:DrawTreeNode(position)
	else
		self.Instance.Position = UDim2.fromOffset(position.X, position.Y)
	end
end

function TreeNode:UpdateTreeNode(pressed: boolean)
	if self.Instance == nil then
		return
	end

	if pressed == true then
		self.Value[1] = not self.Value[1]
		self.InternalValue = self.Value[1]
		self.Instance.dropdown.Rotation = (self.Value[1] == true) and 0 or -90
	elseif self.InternalValue ~= self.Value[1] then
		self.InternalValue = self.Value[1]
		self.Instance.dropdown.Rotation = (self.Value[1] == true) and 0 or -90
	end
end

function TreeNode:Destroy()
	if self.Instance ~= nil then
		self.Instance.Parent = nil
		self.Instance:Destroy()
		self.Instance = nil
	end

	setmetatable(self, nil)
end

return TreeNode
