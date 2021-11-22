local Iterator = require("fplua.structs.iterator")

local M = {}

--- Returns an Iterator structure of a numerical sequence with an interval. The starting point is included and the ending point is excluded. For a generic-for iterator, see \`fplua.gens.range.range\`
---```lua
---  local xs = raw_range(10 + 1)
---  local product = xs:foldl(function(acc, x) return acc * x end, 1)
---
---  assert(product == 3628800)
---```
---@param sidx? number
---@param eidx number
---@param step? number
---@return Iterator
function M.raw_range(sidx, eidx, step)
  local seq = {}
  if step == nil then
    -- Imply step
    if eidx == nil then
      -- Set sidx to 0, eidx to sidx
      sidx, eidx = (sidx == 0 and 0 or sidx > 0 and 1 or -1), sidx
    end
    step = (sidx == eidx) and 0 or (sidx < eidx) and 1 or -1
  end

  if step >= 0 then
    while sidx < eidx do
      table.insert(seq, sidx)
      sidx = sidx + step
    end
  end

  if step <= 0 then
    while sidx > eidx do
      table.insert(seq, sidx)
      sidx = sidx + step
    end
  end

  return Iterator.from(seq)
end

--- Returns an generic-for iterator of a numerical sequence with an interval. The starting point is included, and the ending point is excluded. Since Lua is 1 based, this function starts on ±1 if only one argument is passed. For an Iterator structure, see \`fplua.gens.range.raw_range\`
---```lua
---  for x in range(4) do
---    --
---  end -- 1, 2, 3
---
---  for x in range(2, -3) do
---    --
---  end -- 2, 1, 0, -1, -2
---
---  for x in range(4, 10, 2) do
---    --
---  end -- 4, 6, 8
---```
---@param sidx? number
---@param eidx number
---@param step? number
---@return fun(t: number[], k: number): number, number
function M.range(sidx, eidx, step)
  return M.raw_range(sidx, eidx, step):iter()
end

return M
