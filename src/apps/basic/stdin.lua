module(...,package.seeall)

local app = require("core.app")
local packet = require("core.packet")
local link = require("core.link")
local ffi = require("ffi")
local async = require("core.async_std")
local transmit, receive = link.transmit, link.receive
local C = ffi.C

Stdin = {}

function Stdin:new(line_sep)
    local size = 2048 -- tonumber(size) or 60
    -- local data = ffi.new("char[?]", size)
    local p = nil --packet.from_pointer(data, size)

    async.init_async_stdin()    -- set stdin in non-block mode.

    return setmetatable({size=size, packet=p}, {__index=Stdin})
end

function Stdin:pull ()
    local l = self.output.tx
    if l == nil then return end
    local limit = engine.pull_npackets
    while limit > 0 do
        limit = limit - 1
        -- check limit
        local sp, n = async.async_read_stdin(true)
        if n > 0 then
            -- print(ffi.string(sp.data, sp.length))
            -- print(sp.data)
            link.transmit(l, sp)
        end
    end
    --[[
    if engine.pull_npackets - limit > 0 then
       print("raw: pull"..(engine.pull_npackets - limit))
    end
    ]]--
end

function Stdin:stop ()
    -- packet.free(self.packet)
end