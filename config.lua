local pipe = require "pipe"

local config = {
    argv = nil,
    argc = 0,
    name = "dzecnt-container-host",
    mount = nil,
    uid = nil,
    gid = nil,
    -- 1GB
    mem = 1024 * 1024 * 1024 * 1024
}

local opt_handlers = {
    ["-f"] = function(config, argv, i)
        -- TODO: parse file for settings
    end,
    ["-n"] = function(config, argv, i)
        assert(argv[i + 1])
        config.name = argv[i + 1]
    end,
    ["-m"] = function(config, argv, i)
        assert(argv[i + 1])
        config.mount = argv[i + 1]
    end,
    ["-u"] = function(config, argv, i)
        assert(argv[i + 1])
        config.uid = argv[i + 1]
    end,
    ["-g"] = function(config, argv, i)
        assert(argv[i + 1])
        config.gid = argv[i + 1]
    end,
    ["-c"] = nil -- Just to make sure.
}

function config:new()
    self.__index = self

    local obj = {
        pipe = pipe:new()
    }

    return setmetatable(obj, self)
end

function config:parse(argv)
    local argc = #argv
    local name = argv[0]
    argv[0] = nil

    if not argv[1] then
        self:usage(name)
        os.exit()
    end

    local i = 1
    while i <= argc do
        if argv[i] == "-h" then
            self:usage(name)
            os.exit()
        elseif opt_handlers[argv[i]] then
            opt_handlers[argv[i]](self, argv, i)
            i = i + 1 -- Skip next.
        else
            if argv[i] == "-c" or (i == 1 and argv[i]:sub(1,1) ~= '-') then
                if argv[i] == "-c" then
                    i = i + 1
                end

                self.argv = {}

                -- Copy the remainder as argv of the
                -- executed command.
                local j = 1
                while i <= argc do
                    self.argv[j] = argv[i]
                    i = i + 1
                    j = j + 1
                end
                self.argc = j - 1

                return self
            end
            -- TODO: Log error.
        end

        i = i + 1
    end

    return self
end

function config:usage(name)
    print(string.format([[
Usage: %s [OPTIONS]... -c COMMAND [ARGS]...
Options:
    -c COMMAND      specifies command to run,
                    can be omitted if no other
                    options are used
    -f FILE         config file to read
    -h              print this message
    -m PATH         mount point path
    -n NAME         hostname
    -u MAP          uid map
    ]], name))
end

return config
