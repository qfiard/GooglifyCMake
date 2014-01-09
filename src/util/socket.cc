#include "util/socket.h"

#include "gflags/gflags.h"

namespace util {

DEFINE_int32(max_buffer_size, 1 << 10,
             "Max buffer size for socket io (in bytes)");

}  // namespace util
