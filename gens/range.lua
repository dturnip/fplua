local Iterator = require("fplua.structs.iterator")

--- Returns an iterator of a numerical sequence with an interval. The starting point is included, and the ending point is excluded.
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
---@param sidx number
---@param eidx? number
---@param step? number
---@return fun(t: number[], k: number): number, number
local function range(sidx, eidx, step)
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

  return Iterator.from(seq):iter()
end

return range
