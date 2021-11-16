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

function Iterator:dbg()
  table.display(self)
end

function Iterator:iter()
  return self.fn, self.t, self.init
end

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

function Iterator:map(fn)
  if type(self.t) ~= "table" then
    error("[ERROR]: Iterator:map can only be used on table iterators")
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

function Iterator:filter(fn)
  if type(self.t) ~= "table" then
    error("[ERROR]: Iterator:filter can only be used on table iterators")
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
