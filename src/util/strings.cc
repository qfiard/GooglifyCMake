#include "util/strings.h"

#include <stdlib.h>
#include <sstream>
#include <iostream>
#include <regex>
#include <unordered_set>
#include "boost/algorithm/string.hpp"
#include "boost/tokenizer.hpp"
#include "util/logging.h"

namespace util {
namespace strings {

std::string Join(const std::vector<std::string> &parts,
                 const std::string &sep) {
  std::stringstream ss;
  bool first = true;
  for (const auto &part : parts) {
    if (!first) ss << sep;
    ss << part;
    first = false;
  }
  return ss.str();
}

std::vector<std::string> Split(const std::string &str,
                               const std::string &separators) {
  CHECK_GT(separators.size(), 0);
  std::unordered_set<char> separator_chars;
  for (const auto &c : separators) {
    separator_chars.insert(c);
  }
  std::string normalized_string = Trim(str, separators);
  for (int i = 0; i < normalized_string.size(); ++i) {
    if (separator_chars.find(normalized_string[i]) != separator_chars.end()) {
      normalized_string[i] = separators[0];
    }
  }
  boost::tokenizer<boost::escaped_list_separator<char> > tokenizer(
      normalized_string,
      boost::escaped_list_separator<char>("\\", separators.substr(0, 1), "\""));
  std::vector<std::string> res;
  for (const auto &token : tokenizer) {
    res.push_back(token);
  }
  return res;
}

char *StrDup(const char *str) {
  char *res = static_cast<char *>(malloc(strlen(str) + 1));
  if (res) snprintf(res, strlen(str) + 1, "%s", str);
  return res;
}

std::string Trim(const std::string &str, const std::string &whitespace) {
  std::size_t begin = str.find_first_not_of(whitespace);
  if (begin == std::string::npos) return "";
  std::size_t end = str.find_last_not_of(whitespace);
  return str.substr(begin, end - begin + 1);
}

}  // namespace strings
}  // namespace util
