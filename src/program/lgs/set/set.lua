module(..., package.seeall)

local counter = require("core.counter")
local ffi = require("ffi")
local lib = require("core.lib")

function show_usage (code)
    print(require("program.lgs.set.README_inc"))
    main.exit(code)
end

function parse_args (raw_args)
    local handlers = {}
    function handlers.h() show_usage(0) end
    function handlers.l ()
        for _, name in ipairs(sort(lwcounter.counter_names)) do
            print(name)
        end
        main.exit(0)
    end
    local args = lib.dogetopt(raw_args, handlers, "h",
        { help="h" })
    if #args > 2 then show_usage(1) end
    if #args == 2 then
        return args[1], args[2]
    end
    return  nil, nil
end

function run (raw_args)
    local key, value = parse_args(raw_args)
    print(value)
    -- local instance_tree = select_snabb_instance(target_pid)
    -- print_counters(instance_tree, counter_name)
end
