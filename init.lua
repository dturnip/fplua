local Iterator = require("fplua.structs.iterator")
local gens_range = require("fplua.gens.range")
local error = require("fplua.utils.error")

return setmetatable({
  Iterator = Iterator,
  range = gens_range.range,
  raw_range = gens_range.raw_range,
}, {
  __call = function(t, conf)
    Iterator.from(t):foreach(function(k, v)
      if rawget(_G, k) then
        if conf["override"] ~= true then
          error(
            string.format(
              "Global field `%s` found and will not be overriden.",
              k
            ),
            2
          )
        end
      end
      rawset(_G, k, v)
    end)
  end,
})
