local ControlModule = {MoveVector = Vector3.new()}

-- Services
local Replicated_Storage = game:GetService("ReplicatedStorage")
local Run_Service = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

function ListenerHandler(self, Name, State, Object)
	if State == Enum.UserInputState.Begin then
		self.Bool = true
		self._Pressed:Fire(Object)
		self.Toggle = not self.Toggle
	elseif State == Enum.UserInputState.End then
		self.Bool = false
		self._Unpressed:Fire(Object)
	end
	self._Changed:Fire(Object)
	return Enum.ContextActionResult.Pass
end

function NewListener(input)
	local self = {Input=input, Name=math.random(1, 1000000)}

	self._Pressed = Instance.new("BindableEvent")
	self._Unpressed = Instance.new("BindableEvent")
	self._Changed = Instance.new("BindableEvent")

	self.Pressed = self._Pressed.Event
	self.Unpressed = self._Unpressed.Event
	self.Changed = self._Changed.Event
	
	self.Toggle = false
	self.Bool = false

	ContextActionService:BindAction(
		self.Name,
		function(Name, State, Object)
			return ListenerHandler(self, Name, State, Object)
		end,
		false,
		self.Input
	)
	return self
end

function ListenerToValue(Listener)
	return Listener.Bool and 1 or 0
end

function NewVectorListener()
	local self = {}
	local W = NewListener(Enum.KeyCode.W)
	local S = NewListener(Enum.KeyCode.S)
	local A = NewListener(Enum.KeyCode.A)
	local D = NewListener(Enum.KeyCode.D)
	self.Listeners = {W,A,S,D}
	self._Changed = Instance.new("BindableEvent")
	for i,v in self.Listeners do
		v.Changed:Connect(function()
			self._Changed:Fire()
			self.Vector = Vector3.new(ListenerToValue(D)-ListenerToValue(A),0,ListenerToValue(S)-ListenerToValue(W))
		end)
	end
	self.Changed = self._Changed.Event
	self.Vector = Vector3.new()
	return self
end

-- Export
ControlModule.NewListener = NewListener
ControlModule.NewVectorListener = NewVectorListener
return ControlModule
