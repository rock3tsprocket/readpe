# readpe
This program is a Lua script that reads (some of) a Portable Executable format executable's headers and prints information about them.

## Dependencies
* A Lua interpreter with the `bit32` library

## How to use
Pass a Portable Executable to the script as its first argument like this:
```
lua readpe.lua <PATH TO EXECUTABLE>
```
