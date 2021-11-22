local Iterator = require("fplua.structs.iterator")
local range = require("fplua.gens.range").range

local M = {}

function M.test_range()
  local xs = {}

  for x in range(4) do
    table.insert(xs, x)
  end

  for x in range(-5, 3) do
    table.insert(xs, x)
  end

  for x in range(8, -8, -3) do
    table.insert(xs, x)
  end

  local sum = Iterator.from(xs):foldl(function(acc, x)
    return acc + x
  end, 0)

  assert(sum == -3)
end

M.test_range()
