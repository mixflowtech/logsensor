module(...,package.seeall)

local app = require("core.app")
local packet = require("core.packet")
local link = require("core.link")
local ffi = require("ffi")
local transmit, receive = link.transmit, link.receive
local C = ffi.C

CliEngine = {}

function CliEngine:new(engine)
    return setmetatable({needs_reconfigure=false, engine=engine}, {__index=CliEngine})
end

function CliEngine:push ()
    for _, i in ipairs(self.input) do
        for _ = 1, link.nreadable(i) do
            local p = receive(i)
            local cmd = ffi.string(p.data, p.length)
            --[[
            -- What a shame, if the engine not running, the cmd can not passed to here
            --               if the engine is stoped, it will not be able running again...
            if cmd == 'run' then
                engine.main({done=function() return self.needs_reconfigure end, report = {showlinks=true}})
            end
            if cmd == 'exit' then
                self.needs_reconfigure = true
            end
            ]]
            -- make a new configuration might reasonable
            packet.free(p)
        end
    end
end
