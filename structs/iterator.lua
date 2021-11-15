local tableutils = require("utils.tableutils")

table.display = tableutils.display

local Iterator = {}
Iterator.__index = Iterator

local function into_iter(t)
	if type(t) == "table" then
		if #t > 0 then
			-- Table is an Array
			local i = 0
			return function()
				i = i + 1
				if i <= #t then
					return t[i]
				end
			end
		else
			-- Table is a Hashmap
		end
	end
end

local xs = into_iter({ 1, 2, 3 })

for x in xs do
	print(x)
end

local hashmap = { a = 1, b = 2, c = 3 }

local pairs_gen = pairs({})

local function map_gen(tab, key)
	local value
	local key, value = pairs_gen(tab, key)
	return key, value
end

for k, v in map_gen, hashmap, nil do
	print(k, v)
end

return Iterator
