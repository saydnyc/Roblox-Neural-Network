local Layer = require(game.ReplicatedStorage.V1.Layer)
local ActivationFunctions = require(game.ReplicatedStorage.Global.ActivationFunctions)

local Network = {}
Network.__index = Network

function Network.New(LayerSizes, LearningRate, ActivationFunction)
	local self = setmetatable({}, Network)

	self.Layers = {}
	self.LearningRate = LearningRate or 0.1
	self.ActivationFunction = ActivationFunction or ActivationFunctions.Sigmoid
	self.Output = {}

	for i = 2, #LayerSizes do
		local inputSize = LayerSizes[i - 1]
		local outputSize = LayerSizes[i]

		self.Layers[i - 1] = Layer.New(
			outputSize,
			inputSize,
			self.LearningRate,
			self.ActivationFunction
		)
	end

	return self
end

function Network.Forward(self, input)
	local output = input

	for _, layer in ipairs(self.Layers) do
		output = layer:Forward(output)
	end

	self.Output = output
	return output
end

function Network.Backward(self, expected)
	local target = expected

	for i = #self.Layers, 1, -1 do
		target = self.Layers[i]:Backward(target)
		-- To fully implement backpropagation, pass sensitivity to previous layers here.
	end
end

function Network.Train(self, input, expected)
	local output = self:Forward(input)

	local totalLoss = 0
	local target = expected

	for i = #self.Layers, 1, -1 do
		target, layerLoss = self.Layers[i]:Train(target)
		totalLoss += layerLoss
	end

	return totalLoss, output
end

return Network
