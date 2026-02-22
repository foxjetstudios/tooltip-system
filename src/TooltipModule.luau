-- Tooltip ModuleScript > Put it in ReplicatedStorage

local Tooltip = {}
Tooltip.__index = Tooltip

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

function Tooltip.new(text)
	if not UserInputService.MouseEnabled or not UserInputService.KeyboardEnabled then
		return nil
	end

	local self = setmetatable({}, Tooltip)

	self.Text = text
	self.HoverTime = 1.3
	self.Offset = Vector2.new(8, 4)

	self.Hovering = false
	self.Active = false
	self.PositionConn = nil

	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = playerGui:FindFirstChild("TooltipGui")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "TooltipGui"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.DisplayOrder = 1e8
		screenGui.Parent = playerGui
	end

	self.Gui = screenGui
	self.Frame = nil
	self.Label = nil

	return self
end

function Tooltip:CreateGui()
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel= 0
	frame.Size = UDim2.fromOffset(0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.AnchorPoint = Vector2.new(0, 1)
	frame.Visible = false
	frame.ClipsDescendants = true
	frame.ZIndex = 1e8
	frame.Parent = self.Gui

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.9
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local padding = Instance.new("UIPadding", frame)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)

	local label = Instance.new("TextLabel", frame)
	label.Name = "TextLabel"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1,1)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.TextWrapped = true
	label.Text = self.Text
	label.TextColor3 = Color3.new(1,1,1)
	label.TextSize = 14
	label.FontFace = Font.fromName("Cartoon", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	label.TextTransparency = 1
	label.ZIndex = 1e8 + 1

	self.Frame = frame
	self.Label = label
end

function Tooltip:DestroyGui()
	if self.Frame then
		self.Frame:Destroy()
		self.Frame = nil
	end
	self.Label = nil
end

function Tooltip:UpdatePosition()
	if not self.Frame then return end

	local pos = UserInputService:GetMouseLocation()
	local cam = workspace.CurrentCamera
	local viewport = (cam and cam.ViewportSize) or Vector2.new(1920, 1080)

	local frameSize = self.Frame.AbsoluteSize
	if frameSize.X == 0 or frameSize.Y == 0 then
		local sx = (self.Frame.Size and self.Frame.Size.X and self.Frame.Size.X.Offset) or 0
		local sy = (self.Frame.Size and self.Frame.Size.Y and self.Frame.Size.Y.Offset) or 0
		frameSize = Vector2.new(sx, sy)
	end

	local desiredX = pos.X + self.Offset.X
	local desiredY = pos.Y + self.Offset.Y

	local anchorX = 0
	local anchorY= 1

	if desiredX + frameSize.X > viewport.X then
		anchorX = 1
		desiredX = pos.X - self.Offset.X
	else
		anchorX = 0
	end

	if desiredY + frameSize.Y > viewport.Y then
		anchorY = 0
		desiredY = pos.X and (pos.Y - self.Offset.Y) or desiredY
	else
		anchorY = 1
	end

	desiredX = math.clamp(desiredX, 0, math.max(0, viewport.X - frameSize.X))
	desiredY = math.clamp(desiredY, 0, math.max(0, viewport.Y - frameSize.Y))

	self.Frame.AnchorPoint = Vector2.new(anchorX, anchorY)
	self.Frame.Position = UDim2.new(0, desiredX, 0, desiredY)
end

function Tooltip:Show()
	if self.Active then return end
	self.Active = true

	if not self.Frame then
		self:CreateGui()
	end

	self.Label.Text = self.Text
	self.Frame.Visible = true
	RunService.Heartbeat:Wait()

	self.Frame.Size = UDim2.fromOffset(self.Label.AbsoluteSize.X + 20, self.Label.AbsoluteSize.Y + 12)
	self:UpdatePosition()

	for i = 1, 0, -0.1 do
		self.Frame.BackgroundTransparency = i
		self.Label.TextTransparency = i
		RunService.Heartbeat:Wait()
	end

	self.Frame.BackgroundTransparency = 0
	self.Label.TextTransparency = 0

	if not self.PositionConn then
		self.PositionConn = RunService.RenderStepped:Connect(function()
			self:UpdatePosition()
		end)
	end
end

function Tooltip:Hide()
	if not self.Active then return end
	self.Active = false

	if self.Frame then
		for i = 0, 1, 0.1 do
			self.Frame.BackgroundTransparency = i
			self.Label.TextTransparency = i
			RunService.Heartbeat:Wait()
		end
	end

	if self.PositionConn then
		self.PositionConn:Disconnect()
		self.PositionConn = nil
	end

	self:DestroyGui()
end

function Tooltip:AttachTo(guiObject)
	if not UserInputService.MouseEnabled or not UserInputService.KeyboardEnabled then
		return
	end
	if not guiObject then
		return
	end

	guiObject.MouseEnter:Connect(function()
		self.Hovering = true
		coroutine.wrap(function()
			local elapsed = 0
			local lastPos = UserInputService:GetMouseLocation()
			while elapsed < self.HoverTime and self.Hovering do
				RunService.Heartbeat:Wait()
				local now = UserInputService:GetMouseLocation()
				if (now - lastPos).Magnitude > 2 then
					elapsed = 0
					lastPos = now
				else
					elapsed += RunService.RenderStepped:Wait() or 0
				end
			end
			if self.Hovering then
				self:Show()
			end
		end)()
	end)

	guiObject.MouseLeave:Connect(function()
		self.Hovering = false
		self:Hide()
	end)
end

return Tooltip
