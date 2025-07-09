local Neuron = require(game.ReplicatedStorage.V1.Neuron)

local Layer = {}
Layer.__index = Layer

function Layer.New(NeuronAmount, InputAmount, LearningRate, ActivationFunction)
	local self = setmetatable({}, Layer)
	self.Neurons = {}
	self.Outputs = {}
	self.Input = {}
	self.NeuronAmount = NeuronAmount
	self.LearningRate = LearningRate or 0.1

	for i = 1, NeuronAmount do
		self.Neurons[i] = Neuron.New(InputAmount, self.LearningRate, ActivationFunction)
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
	local Sensitivities = {}
	local Losses = {}

	for i, neuron in ipairs(self.Neurons) do
		local expected = ExpectedOutputs[i] or 0
		local sensitivity, loss = neuron:Backward(expected)
		Sensitivities[i] = sensitivity
		Losses[i] = loss
	end

	return Sensitivities, Losses
end

function Layer.Train(self, ExpectedOutputs)
	local TotalLoss = 0
	local Sensitivities = {}

	for i, neuron in ipairs(self.Neurons) do
		local expected = ExpectedOutputs[i] or 0
		local sensitivity, loss = neuron:Train(expected)
		Sensitivities[i] = sensitivity
		TotalLoss += loss
	end

	return Sensitivities, TotalLoss / #self.Neurons
end

return Layer
