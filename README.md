# readpe
This program is a Lua script that reads (some of) a Portable Executable format executable's headers and prints information about them.

## Dependencies
* A Lua interpreter with the `bit32` library

## How to use
Pass a Portable Executable to the script as its first argument like this:
```
lua readpe.lua <PATH TO EXECUTABLE>
```

## Sample output
Executing the script with Wine (staging) 11.5's `explorer.exe`:
```
PE header:
  File format: PE
  Machine type: AMD64
  Amount of sections: 17
  Timestamp: Sat Mar 21 15:36:44 2026
  Symbol table pointer: 0xBF000
  Amount of symbols: 7747
  PE type: PE32+
  Characteristics: RELOCS_STRIPPED EXECUTABLE_IMAGE 

Optional header:
  Linker version: 2.45
  Size of code: 69632B
  Size of initialized data: 143360B
  Size of uninitialized data: 143360B
  Entrypoint address: 0x11B00
  Base of code: 0x1000
  Image base: 0x40000000
  Section alignment: 0x1000
  File alignment: 0x1000
  OS version: 4.0
  Image version: 0.0
  Subsystem version: 6.0
  Win32 version value: 0
  Image size: 786432B
  Header size: 4096B
  Checksum: 0xF0BBC
  Subsystem: WINDOWS_GUI (2)
  DLL characteristics: Reserved (0x1) Reserved (0x2) 
  Stack reserve size: 0x200000
  Stack commit size: 0x1000
  Heap reserve size: 0x100000
  Heap commit size: 0x1000
  Loader flags: 0
```
