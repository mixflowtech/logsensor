module(...,package.seeall)

local ffi = require("ffi")
local const = require("syscall.linux.constants")
local packet = require("core.packet")

local C = ffi.C
local uint8_ptr_t = ffi.typeof("uint8_t*")
require("core.async_std_h")

function init_async_stdin()
    return  C.async_setup_stdin()
end

function async_read_stdin(build_packet)
    local key = ffi.new("uint8_t [4096]")
    --[[
        n == -1 and E = EAGAIN, buffer is empty, read it later
        n == 0, EOF
        n > 0,  read data from stdin
     ]]
    local n = C.async_read_stdin(key, 4096)
    if n == -1  and ffi.errno() == const.E.AGAIN then
        -- no more data
        return nil, -1
    end
    if n == 0 then
        return nil, 0
    end
    if build_packet then
        return packet.from_pointer(key, n), n
    else
        return ffi.string(key, n), n
    end
end
