#include "util/csv.h"

#include <vector>
#include <sstream>
#include <string>
#include "boost/algorithm/string/replace.hpp"
#include "boost/tokenizer.hpp"
#include "gflags/gflags.h"

namespace util {
namespace csv {

DEFINE_string(
    csv_escape_character, "\\",
    "Escape character for separators and quotes. Must be a single character");
DEFINE_string(csv_quote_character, "\"",
              "Quote character. Must be a single character");
DEFINE_string(csv_separator, ",",
              "Field separator. Must be a single character");

using google::RegisterFlagValidator;

bool ValidateCharacter(const char *flag_name, const std::string &value) {
  return value.length() == 1;
}

static const bool dummy1 =
    RegisterFlagValidator(&FLAGS_csv_escape_character, ValidateCharacter);
static const bool dummy2 =
    RegisterFlagValidator(&FLAGS_csv_quote_character, ValidateCharacter);
static const bool dummy3 =
    RegisterFlagValidator(&FLAGS_csv_separator, ValidateCharacter);

std::vector<std::string> Parse(const std::string &line) {
  return Parse(line, "\\", "\"", ",");
}

std::vector<std::string> Parse(const std::string &line,
                               const std::string &csv_escape_character,
                               const std::string &csv_quote_character,
                               const std::string &csv_separator) {
  boost::tokenizer<boost::escaped_list_separator<char> > tokenizer(
      line, boost::escaped_list_separator<char>(
                csv_escape_character, csv_separator, csv_quote_character));
  std::vector<std::string> res;
  for (const auto &token : tokenizer) {
    res.push_back(token);
  }
  return res;
}

void WriteCSVLine(const std::vector<std::string> &values, std::ostream *out) {
  WriteCSVLine(values, "\\", "\"", ",", out);
}

void WriteCSVLine(const std::vector<std::string> &values,
                  const std::string &csv_escape_character,
                  const std::string &csv_quote_character,
                  const std::string &csv_separator, std::ostream *out) {
  bool first = true;
  for (auto value : values) {
    if (!first) *out << FLAGS_csv_separator;
    first = false;
    if (value.find(FLAGS_csv_separator) != std::string::npos) {
      // value contains an escape character, we must quote it and thus escape
      // the quotes in it prior to doing so.
      boost::replace_all(
          value, FLAGS_csv_quote_character,
          FLAGS_csv_escape_character + FLAGS_csv_quote_character);
      *out << FLAGS_csv_quote_character << value << FLAGS_csv_quote_character;
    } else {
      *out << value;
    }
  }
  *out << "\n";  // Faster than std::endl, which requires a flush.
}

}  // namespace csv
}  // namespace util
