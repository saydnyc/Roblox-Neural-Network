local Layer = require(game.ReplicatedStorage.V1.Layer)
local ActivationFunctions = require(game.ReplicatedStorage.Global.ActivationFunctions)

local Network = {}
Network.__index = Network

function Network.New(LayerSizes, LearningRate, ActivationFunction)
	local self = setmetatable({}, Network)
	self.Layers = {}
	self.LearningRate = LearningRate or 0.1
	self.ActivationFunction = ActivationFunction or ActivationFunctions.Sigmoid

	for i = 2, #LayerSizes do
		local inputSize = LayerSizes[i - 1]
		local outputSize = LayerSizes[i]
		local layer = Layer.New(outputSize, inputSize, self.LearningRate, self.ActivationFunction)
		table.insert(self.Layers, layer)
	end

	return self
end

function Network.Forward(self, Input)
	local out = Input
	for _, layer in ipairs(self.Layers) do
		out = layer:Forward(out)
	end
	self.Output = out
	return out
end

function Network.Backward(self, Expected)
	local target = Expected
	for i = #self.Layers, 1, -1 do
		target = self.Layers[i]:Backward(target)
		-- You can improve this by computing sensitivity to previous layers for full backpropagation
	end
end

function Network.Train(self, Input, Expected)
	local CurrentOutput = self:Forward(Input)

	local totalLoss = 0
	local target = Expected
	for i = #self.Layers, 1, -1 do
		target, layerLoss = self.Layers[i]:Train(target)
		totalLoss += layerLoss
	end

	return totalLoss,CurrentOutput
end

return Network
