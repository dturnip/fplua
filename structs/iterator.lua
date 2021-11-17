local error = require("fplua.utils.error")

---@class Iterator
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

---Instantiates a new Iterator structure from an indexable built in data structure.
---```lua
--  local chars_iter = Iterator.from("fplua")
--  local array_iter = Iterator.from({ 1, 2, 3 })
--  local map_iter   = Iterator.from({ a = 1, b = 2, c = 3 })
--```
---@param t string | table
---@return Iterator
function Iterator.from(t)
  if type(t) ~= "table" and type(t) ~= "string" then
    error(
      "Argument `t` passed to Iterator.from(t) must be an Array, Hashmap or String.",
      2
    )
  end

  local buf = setmetatable({}, Iterator)
  buf.fn = into_iter(t)
  buf.obj = t

  if type(t) == "table" then
    if #t > 0 then
      -- Array iterator
      buf.state = 0
    else
      -- Hashmap iterator
      buf.state = nil
    end
  elseif type(t) == "string" then
    -- String iterator
    buf.state = 0
  end

  return buf
end

---Pretty prints the Iterator structure to the console.
---```lua
--  local xs = Iterator.from({ 1, 2, 3 })
--  xs:dbg()
--
--  -- table: 0x... {
--  --   [fn] => function: 0x...
--  --   [state] => 0
--  --   [obj] => table: 0x... {
--  --              [1] => 1
--  --              [2] => 2
--  --              [3] => 3
--  --            }
--  --   }
--```
function Iterator:dbg()
  table.display(self)
end

---Returns an iterator from an Iterator structure which can be used in a generic 'for-in' loop. This method is not suggested to be used directly, but can be if for whatever reason necessary.
---```lua
--  local xs = Iterator.from({ 1, 2, 3 })
--  local sum = 0
--
--  for x in xs:iter() do
--    sum = sum + x
--  end
--
--  print(sum) --> 6
--```
---@return fun(t: any, k: any): any, any
---@return string | table
---@return number | nil
function Iterator:iter()
  return self.fn, self.obj, self.state
end

---Collects the Iterator back into the original data structure. This is done by accessing self.obj on an Iterator structure.
---```lua
--  local xs = { 1, 2, 3 }
--
--  local new_xs = Iterator.from(xs)
--		:map(function(x) return x * 2 end)
--		:map(function(x) return x + 1 end)
--		:collect() --> { 3, 5, 7 }
--```
---@return string | table
function Iterator:collect()
  return self.obj
end

---Applies a function to each yielded element(s) from an Iterator. This method shouldn't be used with intent to map an Iterator, instead it is intended to be used for side effects.
---```lua
--  local logins = Iterator.from({ a="a", b="b" })
--  -- BTW this is just an example! It is an absurd way to store login data!
--  local file = io.open("logins.txt", "w+")
--
--  logins:foreach(function(k, v)
--		file:write(string.format("username: %s, password: %s\n", k, v))
--  end)
--
--  file:close()
--```
---@generic K, V
---@param fn fun(k: K, v: V | nil): void
function Iterator:foreach(fn)
  for k, v in self:iter() do
    if v then
      -- Hashmap iterator
      fn(k, v)
    else
      -- Array iterator
      fn(k)
    end
  end
end

---Returns a new Iterator after transforming the values from an Iterator. Since Iterator is a functor, map and alike methods can be chained.
---```lua
--  local colours = {
--    { colour = "red", hex = "FF0000" },
--    { colour = "green", hex = "00FF00" },
--    { colour = "blue", hex = "0000FF" }
--  }
--
--  local colour_map = Iterator.from(colours)
--    :map(function(pair)
--      local ret = {}
--      ret[pair.colour] = pair.hex
--      return ret
--    end)
--    :collect()
--
--  --[[
--  -- {
--  --   { "red" = "FF0000" },
--  --   { "green" = "00FF00" },
--  --   { "blue" = "0000FF" }
--  -- }
--  --]]
--```
---@generic K, V
---@param fn fun(k: K, v: V | nil): any, any
---@return Iterator
function Iterator:map(fn)
  if type(self.obj) ~= "table" then
    error("Iterator:map() can only be used on Array or Hashmap iterators", 2)
    return
  end

  local buf = {}

  for k, v in self:iter() do
    if v then
      -- Hashmap iterator
      local mapped_k, mapped_v = fn(k, v)
      buf[mapped_k] = mapped_v
    else
      -- Array iterator
      local mapped_el = fn(k)
      table.insert(buf, mapped_el)
    end
  end

  return Iterator.from(buf)
end

---Extracts each value from the operand Iterator which returns true after being passed into the function \`fn\` and returns a new Iterator with these.
---```lua
--  local xs = {1, 2, 3, 4, 5, 6, 7, 8}
--
--  local evens = Iterator.from(xs)
--    :filter(function(x) return x % 2 == 0 end)
--    :collect()
--```
---@generic K, V
---@param fn fun(k: K, v: V | nil): boolean
---@return Iterator
function Iterator:filter(fn)
  if type(self.obj) ~= "table" then
    error("Iterator:filter() can only be used on Array or Hashmap iterators", 2)
    return
  end

  local buf = {}

  for k, v in self:iter() do
    if v then
      -- Hashmap iterator
      if fn(k, v) then
        buf[k] = v
      end
    else
      -- Array iterator
      if fn(k) then
        table.insert(buf, k)
      end
    end
  end

  return Iterator.from(buf)
end

return Iterator
