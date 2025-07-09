local Folder = workspace.Viewport
local Part = script.Part
local ControlModule = require(game.ReplicatedStorage.Global.Control)
local Functions = require(game.ReplicatedStorage.Global.Functions)

local DrawModule = {
	Parts = {},
	Input = {},
	Width = 50,
	Height = 50,
	Size = Vector3.new(.5,.5,.5),
	StartPosition = Vector3.new(0,15,5)
}
DrawModule.__index = DrawModule

DrawModule.New = function(Width, Height, Size, StartPosition)
	local self = setmetatable({}, DrawModule)
	
	self.Width = Width or self.Width
	self.Height = Height or self.Height
	self.Size = Size or self.Size
	self.StartPosition = StartPosition or self.StartPosition
	
	return self
end

function DrawModule:Init(LoadPlayerController)
	for y=1, self.Width do
		for x=1, self.Height do
			table.insert(self.Parts, Part:Clone())
			local Index = #self.Parts
			local Part = self.Parts[Index]
			Part.Parent = Folder
			self.Input[Index] = 0
			Part.Size = self.Size
			Part.Position = self.StartPosition - self.Size*Vector3.new(x,y,0)
		end
	end
	if LoadPlayerController then
		self:LoadPlayerController()
	end
end

function DrawModule:Reset()
	for i,v in self.Parts do
		v.Color = Color3.new(0,0,0)
		self.Input[i] = 0
	end
end

function DrawModule:GetNearbyParts(Part)
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = {Folder}
	local Parts = workspace:GetPartBoundsInBox(Part.CFrame, self.Size*1.5, op)
	return Parts
end

function DrawModule:Draw(Part, Nearby)
	if Nearby then
		local GetnearbyParts = DrawModule:GetNearbyParts(Part)
		for i,v in GetnearbyParts do
			v.Color = Color3.new(1,1,1)
			local Index = Functions.SearchByValue(self.Parts, v)
			self.Input[v] = 1
		end
	else
		Part.Color = Color3.new(1,1,1)
		local Index = Functions.SearchByValue(self.Parts, Part)
		self.Input[Index] = 1
	end
end

function DrawModule:LoadPlayerController()
	local Mouse = game.Players.LocalPlayer:GetMouse()
	local MouseClicked = ControlModule.NewListener(Enum.UserInputType.MouseButton1)
	
	game["Run Service"].RenderStepped:Connect(function()
		if MouseClicked.Bool and Mouse.Target and Mouse.Target.Parent == workspace.Viewport then
			DrawModule:Draw(Mouse.Target, false)
		end
	end)
end

return DrawModule
