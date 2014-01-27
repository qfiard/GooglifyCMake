#ifndef UTIL_ABI_H_
#define UTIL_ABI_H_

#include <cxxabi.h>
#include <string>
#include <typeinfo>

namespace util {
namespace abi {

template <class T>
std::string GetDemangledType(const T &object) {
  return ::abi::__cxa_demangle(typeid(object).name(), 0, 0, NULL);
}

}  // namespace abi
}  // namespace util

#endif  // UTIL_ABI_H_
