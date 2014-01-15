#include "util/streams.h"

#include <iostream>
#include <string>

namespace util {
namespace streams {

std::size_t GetNumLines(std::istream *stream) {
  std::size_t num_lines = 0;
  const auto &old_position = stream->tellg();
  std::string line;
  while (std::getline(*stream, line)) ++num_lines;
  stream->clear();
  stream->seekg(old_position);
  return num_lines;
}

void SkipLine(std::istream *stream) {
  std::string line;
  std::getline(*stream, line);
}

}  // namespace streams
}  // namespace util
