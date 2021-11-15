---Pretty prints a lua table with the memory address and key value pairs
---@param t table
local function printTable(t)
	local printTable_cache = {}

	local function sub_printTable(t, indent)
		if printTable_cache[tostring(t)] then
			print(indent .. "*" .. tostring(t))
		else
			printTable_cache[tostring(t)] = true
			if type(t) == "table" then
				for pos, val in pairs(t) do
					if type(val) == "table" then
						print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
						sub_printTable(val, indent .. string.rep(" ", string.len(pos) + 8))
						print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
					elseif type(val) == "string" then
						print(indent .. "[" .. pos .. '] => "' .. val .. '"')
					else
						print(indent .. "[" .. pos .. "] => " .. tostring(val))
					end
				end
			else
				print(indent .. tostring(t))
			end
		end
	end

	if type(t) == "table" then
		print(tostring(t) .. " {")
		sub_printTable(t, "  ")
		print("}")
	else
		sub_printTable(t, "  ")
	end
end

local function dcopy(t)
	if type(t) ~= "table" then
		return t
	end
	local meta = getmetatable(t)
	local target = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			target[k] = dcopy(v)
		else
			target[k] = v
		end
	end
	setmetatable(target, meta)
	return target
end

local rproxies = setmetatable({}, { __mode = "k" })
Readonly = {}

function Readonly.from(t)
	if type(t) == "table" then
		-- Check if entry is in rproxies table
		local proxy = rproxies[t]
		-- Case the proxy doesn't exist
		if not proxy then
			-- Override nil closure proxy variable with a new proxy metatable
			proxy = setmetatable({}, {
				__index = function(_, k)
					return Readonly.from(t[k])
				end,
				__newindex = function()
					error("Can't modify readonly table", 2)
				end,
			})
			-- Uses a weak key as an identifier for the proxy, it is garbage
			-- collected when the original memory address is nullified
			rproxies[t] = proxy
		end
		return proxy
	else
		-- This is usually executed when __index metamethod is called on Readonly
		return t
	end
end

function Readonly.dbg(readtable)
	for k, v in next, rproxies, nil do
		if v == readtable then
			table.display(k)
		end
	end
end

return {
	display = printTable,
	dcopy = dcopy,
}
