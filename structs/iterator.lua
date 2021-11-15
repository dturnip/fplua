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
      return function(t, k)
        return pairs({})(t, k)
      end, t, nil
    end
  elseif type(t) == "string" then
    local i = 0
    return function()
      i = i + 1
      if i <= #t then
        return t:sub(i, i)
      end
    end
  end
end

function Iterator.from(t)
  local buf = setmetatable({}, Iterator)
  buf.fn = into_iter(t)
  buf.t = t

  if type(t) == "table" then
    if #t > 0 then
      -- Array iterator
      buf.init = 0
    else
      -- Hashmap iterator
      buf.init = nil
    end
  elseif type(t) == "string" then
    -- String iterator
    buf.init = 0
  end

  return buf
end

-- local xs = into_iter({ 1, 2, 3 })
--
-- for x in xs do
--   print(x)
-- end
--
-- local hashmap = { a = 1, b = 2, c = 3 }
--
-- for k, v in into_iter(hashmap) do
--   print(k, v)
-- end
-- for char in into_iter("dturnip") do
--   print(char)
-- end

local xs = { 2, 4, 6, 8, 10 }
local xs_iter = Iterator.from(xs)
table.display(xs_iter)

return Iterator
