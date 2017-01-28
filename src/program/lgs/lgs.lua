-- Use of this source code is governed by the Apache 2.0 license; see COPYING.
module(..., package.seeall)
local lib = require("core.lib")
local uv = require('luv')
local S = require("syscall")

local function show_usage(exit_code)
   print(require("program.lgs.README_inc"))
   main.exit(exit_code)
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function run(args)
   if #args == 0 then show_usage(1) end
   local command = string.gsub(table.remove(args, 1), "-", "_")
   local modname = ("program.lgs.%s.%s"):format(command, command)
   if not lib.have_module(modname) then
      show_usage(1)
   end
   require(modname).run(args)
   --[[
   local fd, err = S.open("README.md", "rdonly")
   local stat = uv.fs_fstat(fd:getfd())
   S.close(fd)
   print(dump(stat))
   ]]
end