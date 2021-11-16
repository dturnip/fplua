local tableutils = require("utils.tableutils")
local Iterator = require("structs.iterator")

table.display = tableutils.display
table.dcopy = tableutils.dcopy

local M = {}

function M.test_metatable()
  local nil_iterator = Iterator.from(nil)

  assert(getmetatable(nil_iterator) == Iterator)
end

function M.test_array_iterate()
  local xs = Iterator.from({ 2, 4, 6, 8, 10 })

  local sum_xs = 0

  for x in xs:iter() do
    sum_xs = sum_xs + x
  end

  assert(sum_xs == 30)
end

function M.test_hashmap_iterate()
  local scores = Iterator.from({
    ["raddish"] = 95,
    ["turnip"] = 100,
    ["parsnip"] = 80,
  })

  local best_k
  local best_v = 0

  for k, v in scores:iter() do
    if v > best_v then
      best_v, best_k = v, k
    end
  end

  assert(best_k == "turnip")
end

function M.test_array_foreach()
  local strs = Iterator.from({ "hello", "functional", "lua" })

  local cat_strs = ""

  strs:foreach(function(s)
    cat_strs = cat_strs .. s
  end)

  assert(cat_strs == "hellofunctionallua")
end

function M.test_hashmap_foreach()
  local testdata = Iterator.from({
    a = 1,
    b = 2,
    c = 3,
    d = 4,
  })

  local flat_testdata = {}

  testdata:foreach(function(k, v)
    table.insert(flat_testdata, string.format("%s%s", k, v))
  end)

  table.sort(flat_testdata, function(a, b)
    return a < b
  end)

  assert(table.concat(flat_testdata) == "a1b2c3d4")
end

function M.test_array_map()
  local xs = Iterator.from({ 1, 2, 3, 4, 5 })

  -- Maps can be chained because of a functor pattern
  local squared_xs = xs
    :map(function(x)
      return x ^ 2
    end)
    :map(function(x)
      return x + 1
    end)

  -- This works because it's a single dimensional array
  assert(table.concat(squared_xs.t) == table.concat({
    1 ^ 2 + 1,
    2 ^ 2 + 1,
    3 ^ 2 + 1,
    4 ^ 2 + 1,
    5 ^ 2 + 1,
  }))
end

function M.test_hashmap_map()
  -- TODO: Unit test right here
end

function M.test_array_filter()
  local xs = Iterator.from({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })

  local even_xs = xs:filter(function(x)
    return x % 2 == 0
  end)

  assert(table.concat(even_xs.t) == table.concat({
    2,
    4,
    6,
    8,
    10,
  }))
end

function M.test_hashmap_filter()
  -- TODO: Unit test right here
end

M.test_metatable()
M.test_array_iterate()
M.test_hashmap_iterate()
M.test_array_foreach()
M.test_hashmap_foreach()
M.test_array_map()
M.test_array_filter()
