local utils = require("utils")

table.display = utils.display

local Array = {}
Array.__index = Array

function Array:dbg()
	table.display(self)
end

function Array:map(func)
	local buf = {}
	for _, v in ipairs(self) do
		table.insert(buf, func(v))
	end
	return Array.new(buf)
end

function Array.new(list)
	list = list or {}
	return setmetatable(list, Array)
end

local intArr = Array.new({ 50, 40, 30 })

local mappedIntArr = intArr
	:map(function(v)
		return v * 2
	end)
	:map(function(v)
		return v + 1
	end)
	:map(function(v)
		return v * v
	end)

mappedIntArr:dbg()

-- local function into_iter(t, i)
-- 	i = i or 0
-- 	i = i + 1
-- 	local curr = t[i]
-- 	if curr then
-- 		return i, curr
-- 	end
-- end
--
-- table.into_iter = function(t)
-- 	return into_iter, t, 0
-- end
--
-- for v in table.into_iter(mappedIntArr) do
-- 	print(v)
-- end

return Array
