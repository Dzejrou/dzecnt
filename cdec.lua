local ffi = require "ffi"

ffi.cdef [[
    int execvp(const char* file, char* const argv[]);

    int clone(int (*fn)(void*), void* child_stack,
              int flags, void* args);

    typedef int pid_t;
    pid_t waitpid(pid_t id, int* wstatus, int options);

    int sethostname(const char* name, size_t len);

    int socketpair(int domain, int type, int protocol, int sv[2]);
    ssize_t write(int fd, const void* buf, size_t count);
    ssize_t read(int fd, void* buf, size_t count);

    int mount(const char* source, const char* target,
              const char* filesystemtype, unsigned long mountflags,
              const void* data);

    long syscall(long number, ...);
]]
