#ifndef UTIL_STRINGS_H_
#define UTIL_STRINGS_H_

#include <string>
#include <vector>

namespace util {
namespace strings {

std::string Join(const std::vector<std::string> &parts, const std::string &sep);
std::vector<std::string> Split(const std::string &str,
                               const std::string &separators = " \t");
char *StrDup(const char *str);
std::string Trim(const std::string &str,
                 const std::string &whitespace = " \t\r\n");

}  // namespace strings
}  // namespace util

#endif  // UTIL_STRINGS_H_
