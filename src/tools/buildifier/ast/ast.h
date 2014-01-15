#ifndef TOOLS_BUILDIFIER_AST_AST_CC_
#define TOOLS_BUILDIFIER_AST_AST_CC_

#include <map>
#include <memory>
#include "base/base.h"
#include "tools/buildifier/ast/command.h"
#include "tools/buildifier/ast/target.h"
#include "tools/buildifier/parser/processor.h"
#include "util/algorithm.h"

namespace tools {
namespace buildifier {
namespace ast {

class AST : public parser::Processor {
 public:
  AST() {}
  virtual bool AddCommand(const std::string &command,
                          const std::vector<std::string> &args);
  void Normalize();
  void SaveToBuildFile(const std::string build_file_path) const;

 private:
  std::multiset<std::unique_ptr<Command>, util::algorithm::PointerComparator<
                                              Command> > non_target_commands_;
  std::map<std::string, std::unique_ptr<Target> > targets_;

  DISALLOW_COPY_AND_ASSIGN(AST);
};

}  // namespace ast
}  // namespace buildifier
}  // namespace tools

#endif  // TOOLS_BUILDIFIER_AST_AST_CC_
