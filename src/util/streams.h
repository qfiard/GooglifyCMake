#ifndef UTIL_STREAMS_H_
#define UTIL_STREAMS_H_

#include <iostream>

namespace util {
namespace streams {

std::size_t GetNumLines(std::istream *stream);
void SkipLine(std::istream *stream);

}  // namespace streams
}  // namespace util

#endif  // UTIL_STREAMS_H_
