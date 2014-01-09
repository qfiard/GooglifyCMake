#include "util/system.h"

// To determine the processor count.
#include <mach/mach.h>
#include <mach/mach_host.h>
#include <mach/vm_map.h>

#include <stdio.h>
#include <sys/stat.h>
// To create Unix sockets.
#include <sys/socket.h>
#include <sys/un.h>
#include <cerrno>
#include <string>

#include "util/logging.h"

namespace util {
namespace system {

int GetNumProcessors() {
  processor_cpu_load_info_t newCPUInfo;
  kern_return_t kr;
  unsigned int processor_count;
  mach_msg_type_number_t load_count;

  kr = host_processor_info(
      mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processor_count,
      reinterpret_cast<processor_info_array_t *>(&newCPUInfo), &load_count);
  if (kr != KERN_SUCCESS) {
    LOG(FATAL) << "Can't access processor count.";
    throw;
  } else {
    vm_deallocate(mach_task_self(), reinterpret_cast<vm_address_t>(newCPUInfo),
                  static_cast<vm_size_t>(load_count * sizeof(*newCPUInfo)));
    return static_cast<int>(processor_count);
  }
}

void PrintWithColor(const std::string &str, const Color &color,
                    const bool &bright) {
  if (bright) {
    printf("\x1b[%d;1m%s\x1b[0m", 30 + color, str.c_str());
  } else {
    printf("\x1b[%dm%s\x1b[0m", 30 + color, str.c_str());
  }
}

}  // namespace system
}  // namespace util
