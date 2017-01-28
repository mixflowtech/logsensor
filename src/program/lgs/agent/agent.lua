-- Use of this source code is governed by the Apache 2.0 license; see COPYING.

module(..., package.seeall)

local lib = require("core.lib")
local stdin_app = require("apps.basic.stdin")
local basic_app = require("apps.basic.basic_apps")
local cli_engine_app = require("apps.cli.cli")

local pcap = require("apps.pcap.pcap")
local raw = require("apps.socket.raw")

local usage = require("program.lgs.agent.README_inc")

local long_opts = {
    ["package-path"] = "P",
    interactive = "i",
    name = "n",
    help = "h",
}

function run (raw_args)
    local start_repl = false
    local agent_name = "lgs agent"

    local opt = {}
    function opt.h (arg) print(usage) main.exit(0)            end
    function opt.n (arg) agent_name = arg                     end
    function opt.i (arg) start_repl = true       noop = false end
    function opt.P (arg)
        package.path = arg
    end

    local args = lib.dogetopt(raw_args, opt, "hn:iP:", long_opts)
    -- make a sample app
    --[[
    --  1. A generate Data App
    --  2. Dump to stdout
    --  3. Control by repl ?
     ]]

    local c = config.new()
    config.app(c, "stdin", stdin_app.Stdin, "\n")
    config.app(c, "engine", cli_engine_app.CliEngine, engine)
    config.link(c, "stdin.tx -> engine.rx")

    --[[
    -- packet dump demo
    local interface = 'lo'
    config.app(c, "capture", raw.RawSocket, interface)
    config.app(c, "dump", pcap.StdOutput, {})
    config.link(c, "capture.tx -> dump.input")
    --]]

    engine.configure(c)
    engine.main({report = {showlinks=true}})
    -- handle repl in cli_engine_app
    -- if start_repl then repl() end
end

-- The Master will tell the Agent what to do via this repl shell.
function repl ()
    local line = ''
    local single_line = nil
    local function eval_line ()
        if line:sub(0,1) == "=" then
            -- Evaluate line as expression.
            print(loadstring("return "..line:sub(2))())
        else
            -- Evaluate line as statement
            local load = loadstring(line)
            if load then load() end
        end
    end
    repeat
        io.stdout:write("LGS>")
        io.stdout:flush()
        single_line = io.stdin:read("*l")
        if single_line:sub(#single_line, #single_line) == '\\' then
            line = line .. single_line:sub(0, #single_line - 1)
        else
            line = line .. single_line
            if line then
                local status, err = pcall(eval_line)
                if not status then
                    io.stdout:write(("Error in %s\n"):format(err))
                end
                io.stdout:flush()
                line = ''
            end
        end
    until not single_line
end

