require "cdec"
local ffi = require "ffi"
local const = require "const"

local pipe = {}

function pipe:new(buf_sz)
    self.__index = self
    local obj = {}

    obj.fds = ffi.new("int[2]")
    obj.buf = ffi.new("char[?]", buf_sz or 1)
    obj.buf_sz = buf_sz or 1

    if ffi.C.socketpair(
        const.net.af_unix, const.net.sock_stream,
        0, obj.fds) ~= 0 then
        error("Failed to create socket pair for pipe.")
    end

    return setmetatable(obj, self)
end

function pipe:write(str)
    str = str or "."

    assert(str:len() <= self.buf_sz)
    ffi.copy(self.buf, str)

    ffi.C.write(self.fds[0], self.buf, str:len())
end

function pipe:read()
    ffi.C.read(self.fds[1], self.buf, self.buf_sz)

    return ffi.string(self.buf)
end

return pipe
