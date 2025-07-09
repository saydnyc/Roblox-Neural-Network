	local FunctionsModule = require(game.ReplicatedStorage.Global.Functions)
	local LossFunctions = require(game.ReplicatedStorage.Global.LossFunctions)
	local ActivationFunctions = require(game.ReplicatedStorage.Global.ActivationFunctions)

	local Neuron = {
		InputAmount = 1,
		ActivationFunction = ActivationFunctions.Sigmoid,
		Output = 0,
		LearningRate = .1,
		PreActivatedOutput = 0,
		Loss=0
	}Neuron.__index = Neuron

	Neuron.__call = function(self, Input)
		self:Forward(Input)
	end

	function Neuron.New(InputAmount, LearningRate, ActivationFunction, Weights)
		local self = setmetatable({}, Neuron)
		self.Input = FunctionsModule.rndTableOfNumbers(InputAmount or self.InputAmount)
		self.Input[0] = 1
		self.LearningRate = LearningRate or self.LearningRate
		self.ActivationFunction = ActivationFunction or self.ActivationFunction
		self.Weights = Weights or FunctionsModule.rndTableOfNumbers(#self.Input)
		self.Weights[0] = FunctionsModule.rndNumber(-500,500,100)
		return self
	end

	function Neuron.Forward(self, Input)
		if #Input ~= #self.Input then
			error("Input size mismatch")
		end
		
		local NeuronsInput = Input or self.Input
		NeuronsInput[0] = 1
		self.Input = NeuronsInput
		
		local Output = 0
		
		for i=0, #self.Input do
			Output += (self.Input[i]*self.Weights[i])
		end
		
		self.PreActivatedOutput = Output
		Output = self.ActivationFunction(Output)
		self.Output = Output
		
		return Output
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

		for i = 0, #self.Input do
			self.Weights[i] = self.Weights[i] - self.LearningRate * Sensitivity * self.Input[i]
		end

		return Sensitivity, Loss
	end

	return Neuron
