local FunctionsModule = require(game.ReplicatedStorage.Global.Functions)
local LossFunctions = require(game.ReplicatedStorage.Global.LossFunctions)
local ActivationFunctions = require(game.ReplicatedStorage.Global.ActivationFunctions)

local Neuron = {
	InputAmount = 1,
	ActivationFunction = ActivationFunctions.Sigmoid,
	Input = {},
	Output = 0,
	LearningRate = .1,
	PreActivatedOutput = 0,
	Loss=0,
	Weights = {}
}Neuron.__index = Neuron

function Neuron.New(InputAmount, LearningRate, ActivationFunction, Weights, Bias)
	local self = setmetatable({}, Neuron)
	
	self.InputAmount = InputAmount or self.InputAmount
	self.LearningRate = LearningRate or self.LearningRate
	self.ActivationFunction = ActivationFunction or self.ActivationFunction
	self.Weights = Weights or FunctionsModule.rndTableOfNumbers(self.InputAmount)
	self.Bias = Bias or FunctionsModule.rndNumber(-100,100,100)
	self.Input = FunctionsModule.GenerateTable(self.InputAmount)
	
	return self
end

function Neuron.Forward(self, Input)
	if #Input ~= #self.Input then error("Input size mismatch") end
	self.Input = Input
	local Output = 0

	for i,v in self.Input do
		Output += (v*self.Weights[i])
	end Output += self.Bias

	self.PreActivatedOutput = Output
	Output = self.ActivationFunction(Output)
	self.Output = Output

	return self.Output
end

function Neuron.Backward(self, Expected)
	local Loss = LossFunctions.MSE(self.Output, Expected)
	self.Loss = Loss

	local PreActivation = self.PreActivatedOutput

	local OutputLoss = self.Output - Expected
	local DerivativePreActivation = self.ActivationFunction(PreActivation, true)
	local Sensitivity = OutputLoss * DerivativePreActivation

	return Sensitivity, Loss
end

function Neuron.Train(self, Expected)
	local Sensitivity, Loss = self:Backward(Expected)

	for i,v in self.Input do
		self.Weights[i] = self.Weights[i] - self.LearningRate * Sensitivity * v
	end self.Bias = self.Bias - self.LearningRate * Sensitivity

	return Sensitivity, Loss
end

return Neuron
