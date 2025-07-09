local LossFunctions = {}
-- Updated to handle both scalar and table inputs

-- Helper to check if value is a table
local function isTable(value)
	return type(value) == "table"
end

-- Mean Squared Error (MSE)
LossFunctions.MSE = function(output, target, derivative)
	if not isTable(output) then
		local diff = output - target
		return derivative and (2 * diff) or (diff * diff)
	end

	local sum = 0
	local grad = {}
	for i = 1, #output do
		local diff = output[i] - target[i]
		if derivative then
			grad[i] = 2 * diff
		else
			sum = sum + diff * diff
		end
	end
	return derivative and grad or sum / #output
end

-- Mean Absolute Error (MAE)
LossFunctions.MAE = function(output, target, derivative)
	if not isTable(output) then
		local diff = output - target
		return derivative and ((diff > 0 and 1) or (diff < 0 and -1) or 0) or math.abs(diff)
	end

	local sum = 0
	local grad = {}
	for i = 1, #output do
		local diff = output[i] - target[i]
		if derivative then
			grad[i] = (diff > 0 and 1) or (diff < 0 and -1) or 0
		else
			sum = sum + math.abs(diff)
		end
	end
	return derivative and grad or sum / #output
end

-- Binary Cross Entropy
LossFunctions.BinaryCrossEntropy = function(output, target, derivative)
	local function clamp(x)
		return math.max(1e-7, math.min(1 - 1e-7, x))
	end

	if not isTable(output) then
		local y_hat = clamp(output)
		if derivative then
			return (y_hat - target) / (y_hat * (1 - y_hat))
		else
			return -(target * math.log(y_hat) + (1 - target) * math.log(1 - y_hat))
		end
	end

	local sum = 0
	local grad = {}
	for i = 1, #output do
		local y = target[i]
		local y_hat = clamp(output[i])
		if derivative then
			grad[i] = (y_hat - y) / (y_hat * (1 - y_hat))
		else
			sum = sum - (y * math.log(y_hat) + (1 - y) * math.log(1 - y_hat))
		end
	end
	return derivative and grad or sum / #output
end

-- Categorical Cross Entropy
LossFunctions.CategoricalCrossEntropy = function(output, target, derivative)
	local function clamp(x)
		return math.max(1e-7, x)
	end

	if not isTable(output) then
		error("CategoricalCrossEntropy expects tables for output and target")
	end

	local sum = 0
	local grad = {}
	for i = 1, #output do
		local y = target[i]
		local y_hat = clamp(output[i])
		if derivative then
			grad[i] = -y / y_hat
		else
			sum = sum - y * math.log(y_hat)
		end
	end
	return derivative and grad or sum
end

return LossFunctions
