local tableutils = require("fplua.utils.tableutils")
local error = require("fplua.utils.error")

table.display = tableutils.display

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

--- Instantiates a new Iterator structure from an indexable built in data structure.
---```lua
---  local chars_iter = Iterator.from("fplua")
---  local array_iter = Iterator.from({ 1, 2, 3 })
---  local map_iter   = Iterator.from({ a = 1, b = 2, c = 3 })
---```
---@param t string|table
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

--- Pretty prints the Iterator structure to the console.
---```lua
---  local xs = Iterator.from({ 1, 2, 3 })
---  xs:dbg()
---```
function Iterator:dbg()
  table.display(self)
end

--- Returns an iterator from an Iterator structure which can be used in a generic 'for-in' loop. This method is not suggested to be used directly, but can be if for whatever reason necessary.
---```lua
---  local xs = Iterator.from({ 1, 2, 3 })
---  local sum = 0
---
---  for x in xs:iter() do
---    sum = sum + x
---  end
---
---  print(sum) --> 6
---```
---@return fun(t: any, k: any): any, any
---@return string | table
---@return number | nil
function Iterator:iter()
  return self.fn, self.obj, self.state
end

--- Collects the Iterator back into the original data structure. This is done by accessing self.obj on an Iterator structure.
---```lua
---  local xs = { 1, 2, 3 }
---
---  local new_xs = Iterator.from(xs)
---		:map(function(x) return x * 2 end)
---		:map(function(x) return x + 1 end)
---		:collect() --> { 3, 5, 7 }
---```
---@return string | table
function Iterator:collect()
  return self.obj
end

--- Applies a function to each yielded element(s) from an Iterator. This method shouldn't be used with intent to map an Iterator, instead it is intended to be used for side effects. The below example is to portray how the method works, it's an absurd way to store logins.
---```lua
---  local logins = Iterator.from({ a="a", b="b" })
---  local file = io.open("logins.txt", "w+")
---
---  logins:foreach(function(k, v)
---		file:write(string.format("username: %s, password: %s\n", k, v))
---  end)
---
---  file:close()
---```
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

--- Returns a new Iterator after transforming the values from an Iterator. Since Iterator is a functor, map and alike methods can be chained with any Iterator method that takes self.
---```lua
---  local colours = {
---    { colour = "red", hex = "FF0000" },
---    { colour = "green", hex = "00FF00" },
---    { colour = "blue", hex = "0000FF" }
---  }
---
---  local colour_map = Iterator.from(colours)
---    :map(function(pair)
---      local ret = {}
---      ret[pair.colour] = pair.hex
---      return ret
---    end)
---    :collect()
---
---  -- {
---  --   { "red" = "FF0000" },
---  --   { "green" = "00FF00" },
---  --   { "blue" = "0000FF" }
---  -- }
---```
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

--- Extracts each value from the operand Iterator which returns true after being passed into the function \`fn\` and returns a new Iterator with these.
---```lua
---  local xs = {1, 2, 3, 4, 5, 6, 7, 8}
---
---  local evens = Iterator.from(xs)
---    :filter(function(x) return x % 2 == 0 end)
---    :collect()
---```
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

---Checks each value of an Iterator with a boolean function until a check is passed and returns true. Otherwise, returns false.
---```lua
---  local xs = {1, 5, 6, 8, 12}
---  local has_even = Iterator.from(xs)
---    :any(function(x) return x % 2 == 0 end)
---
---  assert(has_even)
---```
---@generic K, V
---@param fn fun(k: K, v: V | nil): boolean
---@return boolean
function Iterator:any(fn)
  for k, v in self:iter() do
    if v then
      -- Hashmap iterator
      if fn(k, v) == true then
        return true
      end
    else
      -- Array iterator
      if fn(k) == true then
        return true
      end
    end
  end

  return false
end

--- Checks all values of an Iterator with a boolean function. If all checks pass, returns true.
---```lua
---  local words = { "turnip", "radish", "potato" }
---  local all_six = Iterator.from(words)
---    :every(function(s) return #s == 6 end)
---
---  assert(all_six)
---```
---@generic K, V
---@param fn fun(k: K, v: V | nil): boolean
---@return boolean
function Iterator:every(fn)
  for k, v in self:iter() do
    if v then
      -- Hashmap iterator
      if fn(k, v) == false then
        return false
      end
    else
      -- Array iterator
      if fn(k) == false then
        return false
      end
    end
  end

  return true
end

--- Reduces an Iterator from left to right and returns an accumulated value.
---```lua
---  local raw_range = require("fplua.gens.range").raw_range
---  local sum_ten = raw_range(10 + 1)
---    :foldl(function(acc, x) return acc + x end, 0)
---
---  assert(sum_ten == 55)
---```
---@generic T
---@param fn fun(acc: T, k: any, v: any | nil): T
---@param init T
---@return T
function Iterator:foldl(fn, init)
  if init == nil then
    error("Argument <init> in Iterator:foldl(fn, init) is required", 2)
  end

  for k, v in self:iter() do
    if v then
      -- Hashmap iterator
      init = fn(init, k, v)
    else
      -- Array iterator
      init = fn(init, k)
    end
  end

  return init
end


return Iterator
