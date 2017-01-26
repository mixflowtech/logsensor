-- Use of this source code is governed by the Apache 2.0 license; see COPYING.
module(..., package.seeall)
local lib = require("core.lib")

local function show_usage(exit_code)
   print(require("program.lgs.README_inc"))
   main.exit(exit_code)
end

function elementText(el)
   local pieces = {}
   for _,n in ipairs(el.kids) do
      if n.type=='element' then pieces[#pieces+1] = elementText(n)
      elseif n.type=='text' then pieces[#pieces+1] = n.value
      end
   end
   return table.concat(pieces)
end

function run (parameters)
   --
   local SLAXML = require('lib.slaxml.slaxdom')
   local myxml = '<a>测试</a>'
   local doc = SLAXML:dom(myxml)
   print(doc.root)
   print(elementText(doc.root))
end
