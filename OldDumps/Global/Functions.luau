local Functions = {}

Functions.AddAll = function(...) : number
	local y = 0
	
	for i,v in {...} do
		local vType = typeof(v)
		if vType == "number" then
			y += v
		elseif vType == "table" then
			y += Functions.AddAll(v)
		end
	end
	
	return y
end

Functions.rndNumber = function(Range1, Range2, Normalizer)
	Normalizer = Normalizer or 1
	return math.random(math.min(Range1, Range2,0),math.max(Range1, Range2))/Normalizer
end

Functions.rndTableOfNumbers = function(Amount)
	local output = {}
	for i=1,Amount do output[i] = Functions.rndNumber(-100,100,100) end
	return output
end

Functions.SearchByValue = function(Table, Value)
	local Index = nil
	for i,v in Table do
		if v==Value then
			Index = i
		end
	end
	return Index
end

Functions.GenerateTable = function(Size, DefaultValue, OddIndex, OddValue)
	local Output = {}
	for i=1, Size do
		Output[i] = DefaultValue or 0
	end
	if OddIndex then
		Output[OddIndex] = OddValue or 1
	end
	return Output
end

return Functions
