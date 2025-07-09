	local Neuron = require(game.ReplicatedStorage.V1.Neuron)

local Layer = {}
Layer.__index = Layer

function Layer.New(NeuronAmount, InputAmount, LearningRate, ActivationFunction)
	local self = setmetatable({}, Layer)

	self.NeuronAmount = NeuronAmount or 1
	self.InputAmount = InputAmount or 1
	self.LearningRate = LearningRate or 0.1
	self.ActivationFunction = ActivationFunction
	self.Input = {}
	self.Outputs = {}
	self.Neurons = {}

	for i = 1, self.NeuronAmount do
		self.Neurons[i] = Neuron.New(
			self.InputAmount,
			self.LearningRate,
			self.ActivationFunction
		)
	end

	return self
end

function Layer.Forward(self, Input)
	self.Input = Input
	self.Outputs = {}

	for i, neuron in ipairs(self.Neurons) do
		self.Outputs[i] = neuron:Forward(Input)
	end

	return self.Outputs
end

function Layer.Backward(self, ExpectedOutputs)
	local sensitivities = {}
	local losses = {}

	for i, neuron in ipairs(self.Neurons) do
		local expected = ExpectedOutputs[i] or 0
		local sensitivity, loss = neuron:Backward(expected)
		sensitivities[i] = sensitivity
		losses[i] = loss
	end

	return sensitivities, losses
end

function Layer.Train(self, ExpectedOutputs)
	local totalLoss = 0
	local sensitivities = {}

	for i, neuron in ipairs(self.Neurons) do
		local expected = ExpectedOutputs[i] or 0
		local sensitivity, loss = neuron:Train(expected)
		sensitivities[i] = sensitivity
		totalLoss += loss
	end

	local averageLoss = totalLoss / #self.Neurons
	return sensitivities, averageLoss
end

return Layer
