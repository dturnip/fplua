# fplua

fplua is an experimental pure Lua library introducing functional programming utilities

- [x] **Declarative:** Stop writing your own iterators and loops! fplua comes with a bunch of functions that will save you time and boost code readability.
- [x] **Familiar Syntax:** fplua's syntax and flow is inspired by Rust Iterators and Java Streams.
- [x] **Easy And Safe:** fplua is built with pure Lua and has no external dependencies.

## Installation

Note: fplua is created and tested with Lua 5.4. Compatability with previous versions of Lua hasn't been tested, but it should work. Also, if you wish to get intellisense from your text editor/language server, you can clone this library into your project directory instead.

To install fplua:

1. Create a new directory that is recognized in `package.path`

```
mkdir /usr/local/share/lua/5.4/fplua
```

2. Clone the library into this new directory

```
git clone https://github.com/dturnip/fplua.git /usr/local/share/lua/5.4/fplua
```

## Examples

Filterin out even numbers from an array of integers

```lua
local Iterator = require("fplua.structs.iterator")

local xs = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
local evens = Iterator.from(xs)
  :filter(function(x) return x % 2 == 0 end)
  :collect()
```
