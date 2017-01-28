-- Use of this source code is governed by the Apache 2.0 license; see COPYING.

module(...,package.seeall)

local ffi = require("ffi")

local app  = require("core.app")
local link = require("core.link")
local packet = require("core.packet")

SimpleLogFileReader = {}

function SimpleLogFileReader:new (filename)
    -- local file_handler = io.open(filename, "r")
    local records = pcap.records(filename)
    return setmetatable({iterator = records, done = false},
        {__index = PcapReader})
end

function SimpleLogFileReader:pull ()
    -- Can not hold the file handler for a long time, for the application might write the file
    -- Check the file stats withn knowned status
    -- If changed reopen the file.
    assert(self.output.output)
    local limit = engine.pull_npackets
    while limit > 0 and not self.done do
        limit = limit - 1
        local data, record, extra = self.iterator()
        if data then
            local p = packet.from_string(data)
            link.transmit(self.output.output, p)
        else
            self.done = true
        end
    end
end

function SimpleLogFileReader:stop ()
    -- packet.free(self.packet)
end