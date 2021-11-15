local tableutils = require("utils.tableutils")

table.display = tableutils.display

local Array = {}
Array.__index = Array

local function iter(t)
  local i = 0
  return function()
    i = i + 1
    if i <= #t then
      return t[i]
    end
  end
end

function Array:dbg()
  table.display(self)
end

function Array:map(func)
  local buf = {}
  for el in iter(self) do
    table.insert(buf, func(el))
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

return Array
