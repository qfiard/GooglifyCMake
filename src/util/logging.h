#ifndef UTIL_LOGGING_H_
#define UTIL_LOGGING_H_

#include <string>
#include <vector>
#include "g2log/g2log.h"
#include "g2log/g2logworker.h"

#define G2_LOG_ERROR \
  g2::internal::LogMessage(__FILE__, __LINE__, __PRETTY_FUNCTION__, "ERROR")

#define CHECK_EQ(a, b) CHECK(a == b)
#define CHECK_NE(a, b) CHECK(a != b)
#define CHECK_LE(a, b) CHECK(a <= b)
#define CHECK_LT(a, b) CHECK(a < b)
#define CHECK_GE(a, b) CHECK(a >= b)
#define CHECK_GT(a, b) CHECK(a > b)

namespace util {
namespace logging {
void Init(const int &argc, char **argv,
          const std::string &log_directory = "/tmp");
void Init(const std::string &name, const std::string &log_directory = "/tmp");
}  // namespace logging
}  // namespace util

template <class T>
    std::ostream &operator<<(std::ostream &os, const std::vector<T> &v) {
  os << "[";
  bool first = true;
  for (const auto &value : v) {
    if (!first) os << ", ";
    os << value;
    first = false;
  }
  return os << "]";
}

#endif
