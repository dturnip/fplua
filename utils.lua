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
