#!/usr/bin/env lua

--[[ Copyright 2026 rock3tsprocket

 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this list of conditions and
 the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.

 3. Neither the name of the copyright holder nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. ]]

bit32 = require("bit32")

-- Constants, like, a lot of constants
-- I'm not sure of a better way to do this
-- (https://learn.microsoft.com/en-us/windows/win32/debug/pe-format)
MACHINE_TYPES = {}
MACHINE_TYPES[0] = "UNKNOWN"
MACHINE_TYPES[0x184] = "ALPHA"
MACHINE_TYPES[0x284] = "ALPHA64/AXP64"
MACHINE_TYPES[0x1D3] = "AM33"
MACHINE_TYPES[0x8664] = "AMD64"
MACHINE_TYPES[0x1C0] = "ARM"
MACHINE_TYPES[0xAA64] = "ARM64"
MACHINE_TYPES[0xA641] = "ARM64EC"
MACHINE_TYPES[0xA64E] = "ARM64X"
MACHINE_TYPES[0x1C4] = "ARMNT"
MACHINE_TYPES[0xEBC] = "EBC"
MACHINE_TYPES[0x14C] = "I386"
MACHINE_TYPES[0x200] = "IA64"
MACHINE_TYPES[0x6232] = "LOONGARCH32"
MACHINE_TYPES[0x6264] = "LOONGARCH64"
MACHINE_TYPES[0x9041] = "M32R"
MACHINE_TYPES[0x266] = "MIPS16"
MACHINE_TYPES[0x366] = "MIPSFPU"
MACHINE_TYPES[0x466] = "MIPSFPU16"
MACHINE_TYPES[0x1F0] = "POWERPC"
MACHINE_TYPES[0x1F1] = "POWERPCFP"
MACHINE_TYPES[0x160] = "R3000BE"
MACHINE_TYPES[0x162] = "R3000"
MACHINE_TYPES[0x166] = "R4000"
MACHINE_TYPES[0x168] = "R10000"
MACHINE_TYPES[0x5032] = "RISCV32"
MACHINE_TYPES[0x5064] = "RISCV64"
MACHINE_TYPES[0x5128] = "RISCV128"
MACHINE_TYPES[0x1A2] = "SH3"
MACHINE_TYPES[0x1A3] = "SH3DSP"
MACHINE_TYPES[0x1A6] = "SH4"
MACHINE_TYPES[0x1A8] = "SH5"
MACHINE_TYPES[0x1C2] = "THUMB"
MACHINE_TYPES[0x169] = "WCEMIPSV2"

CHARACTERISTICS = {}
CHARACTERISTICS[0x1] = "RELOCS_STRIPPED"
CHARACTERISTICS[0x2] = "EXECUTABLE_IMAGE"
CHARACTERISTICS[0x4] = "LINE_NUMS_STRIPPED"
CHARACTERISTICS[0x8] = "LOCAL_SYMS_STRIPPED"
CHARACTERISTICS[0x10] = "AGGRESSIVE_WS_TRIM"
CHARACTERISTICS[0x20] = "LARGE_ADDRESS_AWARE"
CHARACTERISTICS[0x40] = "Reserved"
CHARACTERISTICS[0x80] = "BYTES_REVERSED_LO"
CHARACTERISTICS[0x100] = "32BIT_MACHINE"
CHARACTERISTICS[0x200] = "DEBUG_STRIPPED"
CHARACTERISTICS[0x400] = "REMOVABLE_RUN_FROM_SWAP"
CHARACTERISTICS[0x800] = "NET_RUN_FROM_SWAP"
CHARACTERISTICS[0x1000] = "SYSTEM"
CHARACTERISTICS[0x2000] = "DLL"
CHARACTERISTICS[0x4000] = "UP_SYSTEM_ONLY"
CHARACTERISTICS[0x8000] = "BYTES_REVERSED_HI"

SUBSYSTEMS = {}
SUBSYSTEMS[0] = "UNKNOWN"
SUBSYSTEMS[1] = "NATIVE"
SUBSYSTEMS[2] = "WINDOWS_GUI"
SUBSYSTEMS[3] = "WINDOWS_CUI"
SUBSYSTEMS[5] = "OS2_CUI"
SUBSYSTEMS[7] = "POSIX_CUI"
SUBSYSTEMS[8] = "NATIVE_WINDOWS"
SUBSYSTEMS[9] = "WINDOWS_CE_GUI"
SUBSYSTEMS[10] = "EFI_APPLICATION"
SUBSYSTEMS[11] = "EFI_BOOT_SERVICE_DRIVER"
SUBSYSTEMS[12] = "EFI_RUNTIME_DRIVER"
SUBSYSTEMS[13] = "EFI_ROM"
SUBSYSTEMS[14] = "XBOX"
SUBSYSTEMS[16] = "WINDOWS_BOOT_APPLICATION"
-- End of constants


-- Function to read little endian data
function read_le(binary, offset, count)
    data = 0
    i=count-1
    while i >= 0 do
    	data = bit32.bor(data, bit32.lshift(string.byte(binary, offset+i+1, offset+i+1), 8*i))
    	i=i-1
    end
    return data
end

if not arg[1] then
    io.stderr:write("Error: No file specified\n")
    return 1
end

f = assert(io.open(arg[1], "rb"))
program = assert(f:read("a"))
assert(f:close())

if string.sub(program, 1, 2) ~= "MZ" then
    io.stderr:write("Error: The specified file is neither a Portable Executable "..
                    "nor a DOS executable (MZ)\n")
    return 1
end

-- Get MZ header size
mz_header_size = read_le(program, 8, 4)

-- Get PE header pointer
pe_header_ptr = read_le(program, mz_header_size*16-4, 4)+1
if string.sub(program, pe_header_ptr, pe_header_ptr+3) ~= "PE\0\0" then
    io.stderr:write("Error: The specified file is not a Portable Executable\n")
    return 1
end

-- Define an offset that gets incremented as the program gets stuff
-- from the executable
offset = pe_header_ptr + 3

-- Get stuff from the COFF header
machine_type = read_le(program, offset, 2)
offset = offset+2
amount_of_sections = read_le(program, offset, 2)
offset = offset+2
timestamp = read_le(program, offset, 4)
offset = offset+8
amount_of_symbols = read_le(program, offset, 4)
offset = offset+4
optional_header_size = read_le(program, offset, 2)
offset = offset+2
characteristics = read_le(program, offset, 2)
offset = offset+2

-- Stuff
if optional_header_size == 0 then
    pe_type = "Object code"
else
    optional_header = read_le(program, offset, 2)
    if optional_header == 0x010b then
        pe_type = "PE32"
    elseif optional_header == 0x020b then
        pe_type = "PE32+"
    end
end


