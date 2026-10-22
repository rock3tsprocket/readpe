# readpe
This program is a Lua script that reads (some of) a Portable Executable format executable's headers and prints information about them.

## Dependencies
* Lua 5.3 or later (due to this script using Lua 5.3's bitwise operators)
    * If your OS doesn't have a package for Lua 5.3 or later, it shouldn't be
      too hard to [build it from source](https://www.lua.org/faq.html#1.1).

## How to use
Pass a Portable Executable to the script as its first argument like this:
```
lua readpe.lua <PATH TO EXECUTABLE>
```
