#ifndef TOOLS_BUILDIFIER_PARSER_PROCESSOR_H_
#define TOOLS_BUILDIFIER_PARSER_PROCESSOR_H_

#include <string>
#include <vector>
#include "base/base.h"

namespace tools {
namespace buildifier {
namespace parser {

class Processor {
 public:
  Processor() {}
  virtual ~Processor() {}
  virtual bool AddCommand(const std::string &command,
                          const std::vector<std::string> &args) = 0;

 private:
  DISALLOW_COPY_AND_ASSIGN(Processor);
};

}  // namespace parser
}  // namespace buildifier
}  // namespace tools

#endif  // TOOLS_BUILDIFIER_PARSER_PROCESSOR_H_
