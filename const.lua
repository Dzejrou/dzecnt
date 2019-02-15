local const = {
    clone = {
        ns   = 0x00020000,
        uts  = 0x04000000,
        ipc  = 0x08000000,
        user = 0x10000000,
        pid  = 0x20000000,
        net  = 0x40000000
    },

    net = {
        af_unix     = 1,
        sock_stream = 1
    },

    sys = {
        pivot_root = 155
    },

    mount = {
        bind    = 0x1000,
        rec     = 0x4000,
        private = bit.lshift(1, 18);
    },

    sigchld = 17
}

const.clone.all = bit.bor(
    const.clone.ns,
    const.clone.uts,
    const.clone.ipc,
    const.clone.user,
    const.clone.pid,
    const.clone.net,
    const.sigchld
)

return const
