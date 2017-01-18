-- Use of this source code is governed by the Apache 2.0 license; see COPYING.

module(...,package.seeall)

local ffi = require("ffi")

local app  = require("core.app")
local link = require("core.link")
local packet = require("core.packet")
local pcap = require("lib.pcap.pcap")
local ethernet = require("lib.protocol.ethernet")
local constants = require("apps.lwaftr.constants")

PcapReader = {}

function PcapReader:new (filename)
   local records = pcap.records(filename)
   return setmetatable({iterator = records, done = false},
                       {__index = PcapReader})
end

function PcapReader:pull ()
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

PcapWriter = {}

function PcapWriter:new (filename)
   local mode = "w"
   if type(filename) == "table" then
      mode = filename[2] or mode
      filename = filename[1]
   end
   local file = assert(io.open(filename, "w"))
   pcap.write_file_header(file)
   return setmetatable({file = file}, {__index = PcapWriter})
end

function PcapWriter:push ()
   while not link.empty(self.input.input) do
      local p = link.receive(self.input.input)
      pcap.write_record_header(self.file, p.length)
      -- XXX expensive to create interned Lua string.
      self.file:write(ffi.string(p.data, p.length))
      self.file:flush()
      packet.free(p)
   end
end

-- RAW Packet Dumper
--[[
   functions `referenced` from lwaftr
 ]]
local lib = require("core.lib")
local bit = require("bit")
local udp  = require("lib.protocol.udp")
local ipv4  = require("lib.protocol.ipv4")

local band, bnot = bit.band, bit.bnot
local rshift, lshift = bit.rshift, bit.lshift
local htons, ntohs, ntohl = lib.htons, lib.ntohs, lib.ntohl

local ethernet_header_size = constants.ethernet_header_size

local function get_ethernet_payload(pkt)
   return pkt.data + ethernet_header_size
end
local function get_ipv4_header_length(ptr)
   local ver_and_ihl = ptr[0]
   return lshift(band(ver_and_ihl, 0xf), 2)
end
local function get_ipv4_total_length(ptr)
   return ntohs(rd16(ptr + o_ipv4_total_length))
end
local function get_ipv4_payload(ptr)
   return ptr + get_ipv4_header_length(ptr)
end

StdOutput = {}

function StdOutput:new ()
   -- FIXME: an option data dump to stderr | stdout
   return setmetatable({prev_ip_id = 0}, {__index = StdOutput})
end

function StdOutput:push ()
   -- ether packet format: source_mac(6), dest_mac(6), pkg_type(2), data[...], checksum(4)\
                                                   -- 0x0800： IP
   --[[
      ip head:
         ver(4bit) ip_head_size(4bit)
         type of service (8bit)
         pkg_length(16bit)
         -
         Identifier(16bit)
         -
         flag(3bit), fragment_offset(13bit)
         -
         ttl(8bit)
         protocol(8bit) --  17    UDP
         checksum(16bit)
         -
         source(32bit)
         -
         -
         -
         dest(32bit)
         -
         -
         -
     ]]
   --[[
      UDP head
         source_port: 16bit
         -
         dest_port: 16bit
         -
         pkg_length: 16bit
         -
         checksum: 16biy
         -
    ]]
   local UDP_HDR_SIZE = 8

   local o_ip_head_size = 12
   local ehs = constants.ethernet_header_size
   while not link.empty(self.input.input) do
      local p = link.receive(self.input.input)
      -- only support ethernet..
      local pkt = ethernet:new_from_mem(p.data, ethernet_header_size)
      local ipv4_header = get_ethernet_payload(p)
      local ip = ipv4:new_from_mem(ipv4_header, get_ipv4_header_length(ipv4_header))
      local udp_header = get_ipv4_payload(ipv4_header)
      local udp = udp:new_from_mem(udp_header, UDP_HDR_SIZE)
      -- dirty fix & work around with the read bug in raw-socket
      if self.prev_ip_id == ip:id() then
         packet.free(p)
      else
         self.prev_ip_id = ip:id()
         -- print(udp:src_port())
         -- print(udp:dst_port())
         -- print(udp:length() - UDP_HDR_SIZE)
         -- print("sss "..payload_size.."==="..p.length.."\n")
         -- print(p.data)    -- output package data to console
         -- print(p.data + ehs+20+8)    -- output package data to console
         -- print('ip: '..ffi.string(ip:src())..' -> '..ffi.string(ip:dst()))
         print(ffi.string(udp_header+UDP_HDR_SIZE, udp:length() - UDP_HDR_SIZE))
         packet.free(p)
      end

   end
end
