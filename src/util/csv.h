#ifndef UTIL_CSV_H_
#define UTIL_CSV_H_

#include <string>
#include <vector>

namespace util {
namespace csv {

std::vector<std::string> Parse(const std::string &line);
std::vector<std::string> Parse(const std::string &line,
                               const std::string &csv_escape_character,
                               const std::string &csv_quote_character,
                               const std::string &csv_separator);
void WriteCSVLine(const std::vector<std::string> &values, std::ostream *out);
void WriteCSVLine(const std::vector<std::string> &values,
                  const std::string &csv_escape_character,
                  const std::string &csv_quote_character,
                  const std::string &csv_separator, std::ostream *out);

}  // namespace csv
}  // namespace util

#endif  // UTIL_CSV_H_
