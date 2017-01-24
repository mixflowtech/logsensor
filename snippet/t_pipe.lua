local posix = require('posix')
local os  = require('os')
local io = require('io')


function splat_popen(data,cmd)
    local rd
    local wr
    rd,wr = posix.pipe()
    io.flush()
    local child = posix.fork()
    if child == 0 then
        rd:close()
        wr:write(data)
        io.flush()
        os.exit(1)
    end
    wr:close()

    local rd2,wr2 = posix.pipe()
    io.flush()
    local child2 = posix.fork()
    if child2 == 0 then
        rd2:close()
        posix.dup(rd,io.stdin)
        posix.dup(wr2,io.stdout)
        posix.exec(cmd)
        os.exit(2)
    end
    wr2:close()
    rd:close()

    y = rd2:read("*a")
    rd2:close()

    posix.wait(child2)
    posix.wait(child)

    return y
end

munged=splat_popen("hello, world","/bin/echo")
print("munged: "..munged.." !")