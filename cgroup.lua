require "cdec"
local ffi = require "ffi"

local cgroup = {}

function cgroup:new(conf)
    local path
    if conf.cgroup_name then
        -- Connect to already existing cgroup.
        path = "/sys/fs/cgroup/" .. conf.cgroup
    else
        -- Create brand new & shiny cgrup.
        path = "/sys/fs/cgroup/dzecnt_" .. tostring(conf.pid)
        ffi.C.mkdir(path, 0775)
    end

    local f = io.open(path .. "/cgroup.procs", "w")
    f:write(conf.pid)
    f:close()
end

return cgroup
