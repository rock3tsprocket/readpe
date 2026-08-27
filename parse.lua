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
-- (https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#machine-types)
MACHINE_TYPES = {}
MACHINE_TYPES[0] = "IMAGE_FILE_MACHINE_UNKNOWN"
MACHINE_TYPES[0x184] = "IMAGE_FILE_MACHINE_ALPHA"
MACHINE_TYPES[0x284] = "IMAGE_FILE_MACHINE_ALPHA64/AXP64"
MACHINE_TYPES[0x1D3] = "IMAGE_FILE_MACHINE_AM33"
MACHINE_TYPES[0x8664] = "IMAGE_FILE_MACHINE_AMD64"
MACHINE_TYPES[0x1C0] = "IMAGE_FILE_MACHINE_ARM"
MACHINE_TYPES[0xAA64] = "IMAGE_FILE_MACHINE_ARM64"
MACHINE_TYPES[0xA641] = "IMAGE_FILE_MACHINE_ARM64EC"
MACHINE_TYPES[0xA64E] = "IMAGE_FILE_MACHINE_ARM64X"
MACHINE_TYPES[0x1C4] = "IMAGE_FILE_MACHINE_ARMNT"
MACHINE_TYPES[0xEBC] = "IMAGE_FILE_MACHINE_EBC"
MACHINE_TYPES[0x14C] = "IMAGE_FILE_MACHINE_I386"
MACHINE_TYPES[0x200] = "IMAGE_FILE_MACHINE_IA64"
MACHINE_TYPES[0x6232] = "IMAGE_FILE_MACHINE_LOONGARCH32"
MACHINE_TYPES[0x6264] = "IMAGE_FILE_MACHINE_LOONGARCH64"
MACHINE_TYPES[0x9041] = "IMAGE_FILE_MACHINE_M32R"
MACHINE_TYPES[0x266] = "IMAGE_FILE_MACHINE_MIPS16"
MACHINE_TYPES[0x366] = "IMAGE_FILE_MACHINE_MIPSFPU"
MACHINE_TYPES[0x466] = "IMAGE_FILE_MACHINE_MIPSFPU16"
MACHINE_TYPES[0x1F0] = "IMAGE_FILE_MACHINE_POWERPC"
MACHINE_TYPES[0x1F1] = "IMAGE_FILE_MACHINE_POWERPCFP"
MACHINE_TYPES[0x160] = "IMAGE_FILE_MACHINE_R3000BE"
MACHINE_TYPES[0x162] = "IMAGE_FILE_MACHINE_R3000"
MACHINE_TYPES[0x166] = "IMAGE_FILE_MACHINE_R4000"
MACHINE_TYPES[0x168] = "IMAGE_FILE_MACHINE_R10000"
MACHINE_TYPES[0x5032] = "IMAGE_FILE_MACHINE_RISCV32"
MACHINE_TYPES[0x5064] = "IMAGE_FILE_MACHINE_RISCV64"
MACHINE_TYPES[0x5128] = "IMAGE_FILE_MACHINE_RISCV128"
MACHINE_TYPES[0x1A2] = "IMAGE_FILE_MACHINE_SH3"
MACHINE_TYPES[0x1A3] = "IMAGE_FILE_MACHINE_SH3DSP"
MACHINE_TYPES[0x1A6] = "IMAGE_FILE_MACHINE_SH4"
MACHINE_TYPES[0x1A8] = "IMAGE_FILE_MACHINE_SH5"
MACHINE_TYPES[0x1C2] = "IMAGE_FILE_MACHINE_THUMB"
MACHINE_TYPES[0x169] = "IMAGE_FILE_MACHINE_WCEMIPSV2"
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
timestamp = read_le(program, offset, 4)
offset = offset+4
