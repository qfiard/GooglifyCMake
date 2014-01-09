#ifndef UTIL_SYSTEM_H_
#define UTIL_SYSTEM_H_

#include <string>

namespace util {
namespace system {

enum Color {
  BLACK = 0,
  RED = 1,
  GREEN = 2,
  YELLOW = 3,
  BLUE = 4,
  MAGENTA = 5,
  CYAN = 6,
  WHITE = 7
};

int GetNumProcessors();
void PrintWithColor(const std::string &str, const Color &color,
                    const bool &bright = true);

}  // namespace system
}  // namespace util

#endif  // UTIL_SYSTEM_H_
