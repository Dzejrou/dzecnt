require "cdec"
local const = require "const"
local ffi = require "ffi"

local cont = {}

local function set_hostname(conf)
    local len = conf.name:len() + 1
    local name = ffi.new("char[?]", len, conf.name)

    return ffi.C.sethostname(name, len)
end

local function set_mapping(conf, pid)
    if conf.uid then
        local f = io.open("/proc/" .. pid .. "/uid_map", "w")
        f:write(conf.uid)
        f:close()
    end

    if conf.gid then
        -- Changing gid_map currently not working for anyone except
        -- root (since 3.18 kernel because of CVE-2014-8989)
        local f = io.open("/proc/" .. pid .. "/gid_map", "w")
        f:write(conf.gid)
        f:close()
    end
end

local function set_mounts(conf)
    -- Prevents propagating of mount changes.
    if ffi.C.mount(nil, "/", nil,
                   bit.bor(const.mount.private, const.mount.rec),
                   nil) ~= 0 then
        error("Failed to remount private.")
    end

    if conf.mount then
        -- TODO: Mount + pivot_root + chdir.
    end

    return ffi.C.mount("proc", "/proc", "proc", 0, nil)
end

-- Callback invoked by clone().
-- Sets up the container and executes the command.
local function launchpad()
    local argv = ffi.new("const char*[?]", cont.conf.argc + 1, cont.conf.argv)
    argv[cont.conf.argc] = nil
    argv = ffi.cast("char**", argv)

    if set_hostname(cont.conf) ~= 0 then
        error("Failed to set hostname.")
    end

    if set_mounts(cont.conf) ~= 0 then
        error("Failed to set mounts.")
    end

    cont.conf.pipe:read()
    return ffi.C.execvp(argv[0], argv)
end

function cont.spawn(conf, flags)
    assert(conf.argc > 0)
    cont.conf = conf

    local stack_size = 1024 * 1024
    local stack = ffi.new("uint8_t[?]", stack_size)

    local pid = ffi.C.clone(launchpad, stack + stack_size, flags, nil)
    set_mapping(conf, pid)
    conf.pipe:write()

    return pid
end

function cont.wait(pid)
    ffi.C.waitpid(pid or -1, nil, 0)
end

return cont
